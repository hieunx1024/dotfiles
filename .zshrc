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
# SDKMAN Configuration
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Set JAVA_HOME points to current SDKMAN java
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion




# Added by Antigravity CLI installer
export PATH="/home/hieunx/.local/bin:$PATH"
