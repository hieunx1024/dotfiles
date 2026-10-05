# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'
alias e='exit'
alias ws='cd ~/CODES/VNPOST/'
alias des='cd ~/Desktop/'
alias ff='fastfetch'
alias ss='source ~/.bashrc'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# Custom Aliases & PATH
export PATH="$HOME/.local/bin:$PATH"

# Neovim wrapper function: 'nvim -h' opens Neovim keybindings cheatsheet
nvim() {
    if [ "$1" = "-h" ] || [ "$1" = "--help-keys" ]; then
        command nvim -R -c "set filetype=markdown" ~/.config/nvim/KEYBINDINGS.md
    else
        command nvim "$@"
    fi
}

alias v='nvim'
alias vim='nvim'

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] && [ -f "$HOME/.config/hypr/scripts/nmtui-themed.sh" ]; then
    alias nmtui="$HOME/.config/hypr/scripts/nmtui-themed.sh"
elif [ -f "$HOME/.config/sway/scripts/nmtui-themed.sh" ]; then
    alias nmtui="$HOME/.config/sway/scripts/nmtui-themed.sh"
elif [ -f "$HOME/.config/hypr/scripts/nmtui-themed.sh" ]; then
    alias nmtui="$HOME/.config/hypr/scripts/nmtui-themed.sh"
fi

# Theme libnewt (nmtui, whiptail) sang Graphite dark
export NEWT_COLORS='root=lightgray,black:border=lightgray,black:window=lightgray,black:shadow=black,black:title=white,black:button=black,lightgray:actbutton=lightgray,black:checkbox=lightgray,black:actcheckbox=black,lightgray:entry=white,black:label=lightgray,black:listbox=lightgray,black:actlistbox=black,lightgray:textbox=lightgray,black:acttextbox=black,lightgray:helpline=gray,black:roottext=lightgray,black:emptyscale=gray,black:fullscale=lightgray,black:disentry=gray,black:compactbutton=black,lightgray:actsellistbox=black,lightgray'

# logind bật KillUserProcesses=yes: đăng xuất/đổi phiên sẽ tắt mọi tiến trình của phiên cũ. Chạy tmux trong
# scope riêng của systemd --user (ngoài phiên đăng nhập) để server tmux và mọi thứ trong nó sống sót qua
# lúc đổi phiên. Đã ở trong tmux, hoặc không có systemd --user (TTY/ssh), thì gọi tmux bình thường.
tmux() {
    if [ -z "$TMUX" ] && [ -n "$XDG_SESSION_ID" ] && systemctl --user show-environment >/dev/null 2>&1; then
        systemd-run --user --scope --quiet --collect -- tmux "$@"
    else
        command tmux "$@"
    fi
}
alias dotfiles='git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles'
alias dotfiles-hypr='git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles-hypr'


__set_prompt() {
  local exit_code=$?
  local c_user='\[\e[38;2;131;165;152m\]'   # Gruvbox blue/aqua (#83a598)
  local c_dir='\[\e[38;2;184;187;38m\]'     # Gruvbox green (#b8bb26)
  local c_git='\[\e[38;2;254;128;25m\]'     # Gruvbox orange (#fe8019)
  local c_gray='\[\e[38;2;146;131;116m\]'   # Gruvbox gray (#928374)
  local c_ok='\[\e[38;2;184;187;38m\]'      # Gruvbox green (#b8bb26)
  local c_err='\[\e[38;2;251;73;52m\]'      # Gruvbox red (#fb4934)
  local c_reset='\[\e[0m\]'

  local symbol="${c_ok}❯${c_reset}"
  [ $exit_code -ne 0 ] && symbol="${c_err}❯${c_reset}"

  local git_info=""
  local branch
  branch=$(git branch 2>/dev/null | sed -n '/^\*/s/^\* //p')
  [ -n "$branch" ] && git_info=" ${c_gray}on${c_reset} ${c_git} ${branch}${c_reset}"

  local dir_str="${PWD/#$HOME/\~}"

  PS1="${c_user}\u${c_reset} ${c_gray}in${c_reset} ${c_dir} ${dir_str}${c_reset}${git_info}\n${symbol} "
}
PROMPT_COMMAND=__set_prompt
export EDITOR="nvim"
export VISUAL="nvim"
export PATH="$HOME/.local/go/bin:$HOME/go/bin:$PATH"
. "$HOME/.cargo/env"
export GSK_RENDERER=gl

# Local customizations / private aliases (not tracked in git)
[ -f "$HOME/.bashrc_local" ] && source "$HOME/.bashrc_local"
