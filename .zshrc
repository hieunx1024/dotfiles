# Zsh Configuration
# (Replaced ML4W loader with a clean config)

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Keybindings
bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# Aliases
alias l='ls -lah'
alias la='ls -a'
alias ll='ls -l'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias c='clear'
alias e='exit'
alias v='nvim'
alias scf='cd ~/.config/sway/ && nvim .'
alias ss='source ~/.zshrc'
alias ff='fastfetch'
alias t='tmux attach || tmux'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'


# Todo.txt shortcuts
alias tde='nvim ~/.config/todo.txt'
tdd() {
    local line=${1:-1}
    [ -f ~/.config/todo.txt ] && sed -i "${line}d" ~/.config/todo.txt
}

# Sway start (optional, commented out)
# if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
#   exec sway
# fi

# Auto-reload daily tasks for todo.sh (once per day)
LAST_RUN_FILE="$HOME/.config/todo_last_run"
TODAY=$(date +%Y-%m-%d)
if [ ! -f "$LAST_RUN_FILE" ] || [ "$(cat "$LAST_RUN_FILE")" != "$TODAY" ]; then
    [ -f ~/.config/todo.txt ] || touch ~/.config/todo.txt
    grep -vFf ~/.config/todo.txt ~/.config/daily.txt >> ~/.config/todo.txt
    echo "$TODAY" > "$LAST_RUN_FILE"
fi

export EDITOR="nvim"
# SDKMAN Configuration & Lazy-loading
export SDKMAN_DIR="$HOME/.sdkman"
export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
export PATH="$SDKMAN_DIR/candidates/maven/current/bin:$SDKMAN_DIR/candidates/java/current/bin:$SDKMAN_DIR/candidates/gradle/current/bin:$PATH"

sdk() {
    unset -f sdk
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
}

# NVM Configuration & Lazy-loading
export NVM_DIR="$HOME/.nvm"
declare -a __nvm_commands=(nvm node npm npx yarn pnpm corepack)

function __init_nvm() {
    for cmd in "${__nvm_commands[@]}"; do
        unalias "$cmd" &>/dev/null
        unset -f "$cmd" &>/dev/null
    done
    
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
    fi
    if [ -s "$NVM_DIR/bash_completion" ]; then
        source "$NVM_DIR/bash_completion"
    fi
}

for cmd in "${__nvm_commands[@]}"; do
    eval "function $cmd() { __init_nvm; $cmd \"\$@\"; }"
done




# Added by Antigravity CLI installer
export PATH="/home/hieunx/.local/bin:$PATH"
