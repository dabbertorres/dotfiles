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

# TODO decide how I want to handle OSX vs Linux vs etc, basically "per machine" config

export KEYTIMEOUT=1

autoload -Uz compinit
compinit
# End of lines added by compinstall

# env vars
export EDITOR=nvim
export VISUAL=nvim
export SHELL=/usr/local/bin/zsh
export _JAVA_AWT_WM_NONREPARENTING=1
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-14-openj9.jdk/Contents/Home
export GOPATH=~/Code/Go
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH=~/.local/bin:/usr/local/bin:$GOPATH/bin:/usr/local/opt/llvm/bin:/usr/local/opt/gcc/bin:/usr/local/opt/make/libexec/gnubin:/usr/local/opt/openssl/bin:/usr/local/Cellar/openjdk/13.0.2+8_2/bin:~/.dotnet/tools:$PATH

# Since I want to use Homebrew Clang, I have to specify where the system root is, for finding system headers and libraries.
# In order for Go to be able to compile C code, I need to set a few of its CGO_* env vars for it to work properly.
export CGO_CFLAGS="-g -O2 -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
export CGO_CPPFLAGS="-g -O2 -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
export CGO_CXXFLAGS="-g -O2 -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"

# Neovim true color support
export NVIM_TUI_ENABLE_TRUE_COLOR=1
# Neovim cursor shape support
export NVIM_TUI_ENABLE_CURSOR_SHAPE=1

source ~/.zsh/zsh-git-prompt/zshrc.sh

function show-pwd() { echo "%F{green}%~%f" }

function precmd {
    PROMPT="%U%n@%m%u $(show-pwd) $(git_super_status)
> "
}

function vim-mode() { echo "%F{yellow}[$1]%f" }

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

# don't enable zsh vim mode if we're running in a (neo)vim terminal:
if [ -z ${VIM} ]; then
    RPROMPT="$(vim-mode I)"
    zle -N zle-line-init
    zle -N zle-keymap-select
fi

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
#alias chmod='chmod --preserve-root'
alias vim=nvim
# force using system python for lldb - avoids a python import error
alias lldb='PATH=/usr/bin lldb'

### completion

# main directory
fpath=(~/.zsh/completion $fpath)

# fancy completion
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# kubectl auto completion
if [ $commands[kubectl] ]; then
    source <(kubectl completion zsh)
fi

# helm auto completion
if [ $commands[helm] ]; then
    source <(helm completion zsh)
fi

## kitty specific stuff
if [ ${TERM} = 'xterm-kitty' ]; then
    alias icat='kitty +kitten icat'

    kitty + complete setup zsh | source /dev/stdin
fi

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
