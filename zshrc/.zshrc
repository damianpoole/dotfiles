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

alias nv="nvim"
alias reload="source ~/.zshrc"
