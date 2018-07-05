# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd nomatch notify
unsetopt beep extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/alec/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# themes
autoload -Uz promptinit
promptinit
prompt walters

# completion settings
setopt complete_aliases
setopt prompt_subst
autoload -Uz vcs_info

# key bindings
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[3~" delete-char

# aliases
alias cl=clear
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias bins='pacman -Ql | grep'
alias chmod='chmod --preserve-root'
alias docker='sudo docker'

# env vars
export EDITOR=vim
export VISUAL=vim
export _JAVA_AWT_WM_NONREPARENTING=1
export GOPATH=~/Code/Go
export PATH=$PATH:~/.local/bin:$GOPATH/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# helper functions
wifi_connect() { nmcli --ask d w c }
go_exec() { $GOPATH/bin/$1 }

