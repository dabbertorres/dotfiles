# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd nomatch notify
unsetopt beep extendedglob
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/aleciverson/.zshrc'

export KEYTIMEOUT=1

autoload -Uz compinit
compinit
# End of lines added by compinstall

# themes
#autoload -Uz promptinit
#promptinit
#prompt walters

source ~/.zsh/zsh-git-prompt/zshrc.sh

#function git-branch() { git rev-parse --abbrev-ref HEAD 2> /dev/null || true }
function show-pwd() { echo "%F{green}%~%f" }
function vim-mode() { echo "%F{yellow}[$1]%f" }

### prompts
# username@hostname (pwd) (git status)
# >
#PROMPT="%U%n@%m%u $(show-pwd) (%F{blue}$(git-branch)%f)
#> "
RPROMPT="$(vim-mode I)"

function precmd {
    PROMPT="%U%n@%m%u $(show-pwd) $(git_super_status)
> "
}

### zsh line edit (zle) widget callbacks
function zle-line-init zle-keymap-select {
    case ${KEYMAP} in
        (vicmd)      VIM_MODE="N" ;;
        (main|viins) VIM_MODE="I" ;;
        (*)          VIM_MODE="I" ;;
    esac
    RPROMPT="$(vim-mode $VIM_MODE)"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

### completion settings
setopt complete_aliases
setopt prompt_subst
autoload -Uz vcs_info

### key bindings
bindkey "\001" beginning-of-line
bindkey "\005" end-of-line
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\^[3~" delete-char

### aliases
alias cl=clear
alias ls='ls -G'
alias grep='grep --color=auto'
alias chmod='chmod --preserve-root'
alias vim=nvim

# env vars
export EDITOR=$(which nvim)
export VISUAL=$(which nvim)
export SHELL=$(which zsh)
export _JAVA_AWT_WM_NONREPARENTING=1
export GOPATH=~/Code/Go
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Neovim true color support
export NVIM_TUI_ENABLE_TRUE_COLOR=1
# Neovim cursor shape support
export NVIM_TUI_ENABLE_CURSOR_SHAPE=1

### completion

# main directory
fpath=(~/.zsh/completion $fpath)

# fancy completion
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# kubectl auto completion
if [ $commands[kubectl] ]; then
    source <(kubectl completion zsh)
fi

## kitty specific stuff
if [ ${TERM} = 'xterm-kitty' ]; then
    alias icat='kitty +kitten icat'

    kitty + complete setup zsh | source /dev/stdin
fi

export PATH=~/.local/bin:/usr/local/bin:$GOPATH/bin:$PATH
if [ $(uname) = 'Darwin' ]; then
    export PATH=/usr/local/opt/llvm/bin:/usr/local/opt/gcc/bin:/usr/local/opt/make/libexec/gnubin:/usr/local/opt/openssl/bin:$PATH
fi
