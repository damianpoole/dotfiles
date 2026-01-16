# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

eval $(/opt/homebrew/bin/brew shellenv)

# User configuration

eval "$(zoxide init zsh)"
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

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
