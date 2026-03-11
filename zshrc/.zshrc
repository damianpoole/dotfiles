# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gpg-agent keychain zoxide)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"

alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

alias cl="clear"

# Source secrets if they exist
if [ -f "$HOME/.config/.zshrc_secrets" ]; then
    source "$HOME/.config/.zshrc_secrets"
elif [ -f "${${(%):-%N}:A:h}/.zshrc_secrets" ]; then
    source "${${(%):-%N}:A:h}/.zshrc_secrets"
fi

require-command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    print -u2 -- "Error: '$1' is required but not installed."
    return 1
  fi
}

wt-default-branch() {
  local git_dir=${1:-.bare}
  local head_ref

  git -C "$git_dir" remote set-head origin -a >/dev/null 2>&1 || true
  head_ref=$(git -C "$git_dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) || return 1
  print -r -- "${head_ref#origin/}"
}

wt-clone() {
  local url=$1
  local name=${2:-${url:t}}
  local default_branch

  if [[ -z "$url" ]]; then
    echo "Usage: wt-clone <repo-url> [directory]"
    return 1
  fi

  name=${name%.git}

  if [[ -z "$name" ]]; then
    echo "Error: Could not determine target directory name."
    return 1
  fi

  if [[ -e "$name" ]]; then
    echo "Error: '$name' already exists."
    return 1
  fi

  mkdir -p "$name" || return 1
  builtin cd -- "$name" || return 1

  git clone --bare "$url" .bare || return 1

  print -r -- "gitdir: ./.bare" > .git || return 1

  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" || return 1
  git fetch origin || return 1

  default_branch=$(wt-default-branch .bare) || {
    echo "Error: Could not determine origin default branch."
    return 1
  }

  git worktree add "$default_branch" "origin/$default_branch"
}

wt-config-apply() {
  local worktree_name=$1
  local config_dir=".wt-config"
  local config="$config_dir/config.json"
  local i
  local src
  local dest
  local full_src
  local full_dest

  if [[ -z "$worktree_name" ]]; then
    echo "Usage: wt-config-apply <worktree-name>"
    return 1
  fi

  require-command jq || return 1

  if [[ ! -d "$worktree_name" ]]; then
    echo "Error: Worktree '$worktree_name' does not exist in the current directory."
    return 1
  fi

  if [[ ! -f "$config" ]]; then
    # Fail silently if there's no config, as not every project will have one
    return 0
  fi

  echo "Applying configurations to '$worktree_name'..."

  if ! jq -e '.files | arrays' "$config" >/dev/null 2>&1; then
    echo "Error: Invalid config file '$config'. Expected a 'files' array."
    return 1
  fi

  while IFS= read -r i; do
    src=$(jq -r '.source' <<< "$i")
    dest=$(jq -r '.destination' <<< "$i")

    full_src="$config_dir/$src"
    full_dest="$worktree_name/$dest"

    if [[ -f "$full_src" ]]; then
      # Ensure destination directory exists before copying
      mkdir -p "$(dirname "$full_dest")"
      cp -f "$full_src" "$full_dest"
      echo "✔ Copied $src -> $dest"
    else
      echo "⚠ Warning: Source file '$full_src' is missing."
    fi
  done < <(jq -c '.files[]' "$config")

  echo "Configuration applied successfully!"
}

wt-add() {
  local branch
  local wt_path
  local base_ref
  local new_branch=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n)
        new_branch=true
        ;;
      -b|--base)
        shift
        if [[ -z "$1" ]]; then
          echo "Usage: wt-add [-n] [-b <base-ref>] <branch> [path]"
          return 1
        fi
        base_ref=$1
        ;;
      -h|--help)
        echo "Usage: wt-add [-n] [-b <base-ref>] <branch> [path]"
        return 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Error: Unknown option '$1'"
        echo "Usage: wt-add [-n] [-b <base-ref>] <branch> [path]"
        return 1
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  branch=$1
  wt_path=${2:-$branch}

  if [[ -z "$branch" ]]; then
    echo "Usage: wt-add [-n] [-b <base-ref>] <branch> [path]"
    return 1
  fi

  if [[ ! -d .bare ]]; then
    echo "Error: .bare repository not found in the current directory."
    return 1
  fi

  git -C .bare fetch --all --prune || return 1

  local success=false

  if [[ "$new_branch" == "true" ]]; then
    if [[ -z "$base_ref" ]]; then
      base_ref=$(wt-default-branch .bare) || {
        echo "Error: Could not determine the origin default branch. Use -b to set one explicitly."
        return 1
      }
      base_ref="origin/$base_ref"
    fi

    git -C .bare worktree add -b "$branch" "../$wt_path" "$base_ref" && success=true
  elif git -C .bare show-ref --verify --quiet "refs/heads/$branch"; then
    git -C .bare worktree add "../$wt_path" "$branch" && success=true
  elif git -C .bare show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C .bare worktree add -b "$branch" "../$wt_path" "origin/$branch" && success=true
  else
    echo "Error: branch '$branch' not found (local or origin)."
    return 1
  fi

  # If the worktree was successfully created, apply configurations
  if [[ "$success" == "true" ]]; then
    wt-config-apply "$wt_path"
  fi
}

ai-sync() {
  local source_dir=".ai/skills"
  local -a worktrees
  local -a skill_roots
  local -a skill_dirs
  local wt_path
  
  if [[ ! -d "$source_dir" ]]; then
    echo "Error: .ai/skills directory not found in current folder."
    return 1
  fi

  local wt
  for wt_path in ./*(/N); do
    wt="${wt_path#./}"
    if [[ "$wt" == ".bare" ]]; then
      continue
    fi
    if [[ -e "$wt/.git" ]]; then
      worktrees+=("$wt")
    fi
  done

  if [[ ${#worktrees[@]} -eq 0 ]]; then
    echo "Error: No worktrees found in current folder."
    return 1
  fi

  skill_dirs=("$source_dir"/*(/N))
  if [[ ${#skill_dirs[@]} -eq 0 ]]; then
    echo "Error: No skills found in '$source_dir'."
    return 1
  fi

  local skill_dir
  local skill_name
  skill_roots=(".github/skills" ".gemini/skills" ".opencode/skill")
  local dest
  local skill_root

  for wt in "${worktrees[@]}"; do
    echo "Syncing skills for worktree: $wt"

    for skill_dir in "${skill_dirs[@]}"; do
      skill_name="${skill_dir##*/}"

      for skill_root in "${skill_roots[@]}"; do
        dest="$wt/$skill_root/$skill_name"
        rm -rf -- "$dest"
        mkdir -p "$dest" || return 1
        cp -Rf "$skill_dir/." "$dest/" || return 1
      done
    done
  done
}

nic() {
    # Ensure this is being run from inside a tmux session
    if [[ -z "$TMUX" ]]; then
        echo "Error: You must be inside a tmux session to run this."
        return 1
    fi

    # (Optional) Rename the current tmux window to the name of the directory
    local dir_name=$(basename "$PWD")
    tmux rename-window "$dir_name"

    # Step 1: Split vertically to create the bottom pane (33% height)
    tmux split-window -v -l 33% -c "$PWD"

    # Step 2: Select the top pane again (pane 0)
    tmux select-pane -t 0

    # Step 3: Split horizontally for the top-right pane (33% width)
    # This leaves the top-left pane with the remaining 67% (2/3rds)
    tmux split-window -h -l 33% -c "$PWD"

    # Step 4: Launch your applications using send-keys
    # Pane 0 is Top-Left
    tmux send-keys -t 0 "nvim ." C-m

    # Pane 1 is Top-Right
    tmux send-keys -t 1 "oc ." C-m

    # Pane 2 is Bottom. Let's clear the screen and leave your cursor there.
    tmux send-keys -t 2 "clear" C-m
    tmux select-pane -t 2
}
alias oc="opencode ."
alias v="nvim"
alias nv="nvim"
alias reload="source ~/.zshrc"
