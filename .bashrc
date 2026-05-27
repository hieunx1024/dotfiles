# Default .bashrc for Arch Linux
[[ -f /etc/bash.bashrc ]] && . /etc/bash.bashrc

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]$ '




# Added by Antigravity CLI installer
export PATH="/home/hieunx/.local/bin:$PATH"
export PATH=$PATH:/opt/jmeter/bin

# Dotfiles Management Alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
