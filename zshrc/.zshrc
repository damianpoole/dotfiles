# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

eval "$(zoxide init zsh)"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gpg-agent keychain zoxide)

source $ZSH/oh-my-zsh.sh

eval $(/opt/homebrew/bin/brew shellenv)

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
elif [ -f "${0:a:h}/.zshrc_secrets" ]; then
    source "${0:a:h}/.zshrc_secrets"
fi

wt-clone() {
  local url=$1
  local name=$2
  
  # 1. Create directory and clone bare
  mkdir -p "$name" && cd "$name"
  git clone --bare "$url" .bare
  
  # 2. Setup the .git file pointer
  echo "gitdir: ./.bare" > .git
  
  # 3. Fix the fetch refspec so worktrees see remote branches
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  
  # 4. Fetch and add the main branch as the first worktree
  git fetch origin
  git worktree add main
}

wt-config-apply() {
  local worktree_name=$1
  local config_dir=".wt-config"
  local manifest="$config_dir/manifest.json"

  if [[ -z "$worktree_name" ]]; then
    echo "Usage: wt-config-apply <worktree-name>"
    return 1
  fi

  if [[ ! -d "$worktree_name" ]]; then
    echo "Error: Worktree '$worktree_name' does not exist in the current directory."
    return 1
  fi

  if [[ ! -f "$manifest" ]]; then
    # Fail silently if there's no manifest, as not every project will have one
    return 0
  fi

  echo "Applying configurations to '$worktree_name'..."

  # Parse JSON and loop through files
  jq -c '.files[]' "$manifest" | while read -r i; do
    local src dest full_src full_dest
    
    src=$(echo "$i" | jq -r '.source')
    dest=$(echo "$i" | jq -r '.destination')

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
  done

  echo "Configuration applied successfully!"
}

wt-add() {
  local branch
  local wt_path
  local new_branch=false

  if [[ "$1" == "-n" ]]; then
    new_branch=true
    shift
  fi

  branch=$1
  wt_path=${2:-$branch}

  if [[ -z "$branch" ]]; then
    echo "Usage: wt-add [-n] <branch> [path]"
    return 1
  fi

  git -C .bare fetch --all --prune

  local success=false

  if [[ "$new_branch" == "true" ]]; then
    git -C .bare worktree add -b "$branch" "../$wt_path" "origin/main" && success=true
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

  if [[ ! -d "$source_dir" ]]; then
    echo "Error: .ai/skills directory not found in current folder."
    return 1
  fi

  local worktrees=()
  local wt
  for wt in */; do
    wt="${wt%/}"
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

  local skill_dir
  local skill_name
  local skill_file
  local dest

  for wt in "${worktrees[@]}"; do
    echo "Syncing skills for worktree: $wt"

    for skill_dir in "$source_dir"/*; do
      [[ -d "$skill_dir" ]] || continue
      skill_name="${skill_dir##*/}"
      skill_file="$skill_dir/SKILL.md"

      if [[ ! -f "$skill_file" ]]; then
        echo "Skipping $skill_name (no SKILL.md)"
        continue
      fi

      dest="$wt/.github/skills/$skill_name"
      mkdir -p "$dest"
      cp -f "$skill_file" "$dest/SKILL.md"

      dest="$wt/.gemini/skills/$skill_name"
      mkdir -p "$dest"
      cp -f "$skill_file" "$dest/SKILL.md"

      dest="$wt/.opencode/skill/$skill_name"
      mkdir -p "$dest"
      cp -f "$skill_file" "$dest/SKILL.md"
    done
  done
}

alias v="nvim"
alias nv="nvim"
alias reload="source ~/.zshrc"
