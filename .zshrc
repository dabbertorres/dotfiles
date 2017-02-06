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

# display current path in prompt
export PS1="[%40<...<%~%<<] $ "

# key bindings
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# aliases
alias cl=clear
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias bins='pacman -Ql | grep'

# env vars
export EDITOR=vim
export VISUAL=vim
export _JAVA_AWT_WM_NONREPARENTING=1

