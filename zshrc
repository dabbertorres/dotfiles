#zmodload zsh/zprof

HISTFILE=$HOME/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd nomatch notify
unsetopt beep extendedglob
bindkey -v

zstyle :compinstall filename '/Users/aleciverson/.zshrc'

# TODO decide how I want to handle OSX vs Linux vs etc, basically "per machine" config

export KEYTIMEOUT=1

export EDITOR=nvim
export VISUAL=nvim
export _JAVA_AWT_WM_NONREPARENTING=1
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home
export GOPATH="$HOME/Code/Go"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export TOOLCHAINS=swift
export CLOUDSDK_PYTHON_SITEPACKAGES=1

export PATH="$HOME/.local/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/usr/local/opt/gcc/bin:$PATH"
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.krew/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

export CC=/usr/local/opt/llvm/bin/clang
export CXX=/usr/local/opt/llvm/bin/clang++

### completion

autoload -Uz compinit
compinit

autoload -U +X bashcompinit && bashcompinit

fpath=(/opt/vagrant/embedded/gems/2.2.14/gems/vagrant-2.2.14/contrib/zsh $fpath)
fpath=($HOME/.zsh/completion $fpath)

if [ $commands[kubectl] ] && [ ! -f "${fpath[1]}/_kubectl" ]; then
   kubectl completion zsh > "${fpath[1]}/_kubectl"

   if [ ! -f "${fpath[1]}/_kubectl_krew" ]; then
       kubectl krew completion zsh > "${fpath[1]}/_kubectl_krew"
   fi
fi

if [ $commands[kubebuilder] ] && [ ! -f "${fpath[1]}/_kubebuilder" ]; then
    kubebuilder completion zsh > "${fpath[1]}/_kubebuilder"
fi

if [ $commands[poetry] ] && [ ! -f "${fpath[1]}/_poetry" ]; then
    poetry completions zsh > "${fpath[1]}/_poetry"
fi

if [ $commands[terraform] ] && [ ! -f "${fpath[1]}/_terraform" ]; then
    complete -o nospace -C $commands[terraform] terraform
fi

if [ $commands[kustomize] ] && [ ! -f "${fpath[1]}/_kustomize" ]; then
    complete -o nospace -C $commands[kustomize] kustomize
fi

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'

# fancy completion
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Since I want to use Homebrew Clang, I have to specify where the system root is, for finding system headers and libraries.
# In order for Go to be able to compile C code, I need to set a few of its CGO_* env vars for it to work properly.
# LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
export CGO_CFLAGS="$(go env CGO_CFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
export CGO_CPPFLAGS="$(go env CGO_CPPFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
export CGO_CXXFLAGS="$(go env CGO_CXXFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
export CGO_FFLAGS="$(go env CGO_FFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
export CGO_LDFLAGS="$(go env CGO_LDFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/ -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"

# Neovim true color support
export NVIM_TUI_ENABLE_TRUE_COLOR=1

# from https://github.com/romkatv/gitstatus
source $(brew --prefix)/opt/gitstatus/gitstatus.prompt.zsh

function show-pwd() { echo " %F{green}%~%f" }

function show-git-status()
{
    if [[ ${GITSTATUS_PROMPT_LEN} -gt 0 ]]; then
        printf " (%s)" "${GITSTATUS_PROMPT}"
    fi
}

function show-jobs()
{
    local num_jobs=$(jobs -d | wc -l)
    num_jobs=$(echo "$num_jobs / 2" | bc)
    if [[ $num_jobs -gt 0 ]]; then
        local word="jobs"
        if [[ $num_jobs -eq 1 ]]; then word="job"; fi
        printf " %%F{cyan}[%d %s]%%f" $num_jobs $word
    fi
}

function show-dirs()
{
    local num_dirs=$(( $(dirs | sed -e 's/ /\n/g' | wc -l) - 1))
    if [[ $num_dirs -gt 0 ]]; then
        printf " %%F{magenta}[%d dirs]%%f" $num_dirs
    fi
}

function show-pyvenv()
{
    if [ -n "${VIRTUAL_ENV}" ]; then
        printf " %%U%%F{yellow}PY:%s%%f%%u" "${VIRTUAL_ENV}"
    fi
}

function precmd
{
    PROMPT="%U%n@%m%u$(show-pwd)$(show-git-status)$(show-pyvenv)$(show-jobs)$(show-dirs)
> "
}

#function vim-mode() { echo "%F{yellow}[$1]%f" }

### zsh line edit (zle) widget callbacks
#function zle-line-init zle-keymap-select
#{
#    case ${KEYMAP} in
#        (vicmd)      VIM_MODE="N" ;;
#        (main|viins) VIM_MODE="I" ;;
#        (*)          VIM_MODE="I" ;;
#    esac
#    RPROMPT="$(vim-mode $VIM_MODE)"
#    zle reset-prompt
#}

# don't enable zsh vim mode if we're running in a (neo)vim terminal:
#if [ -z ${VIM} ]; then
#    RPROMPT="$(vim-mode I)"
#    zle -N zle-line-init
#    zle -N zle-keymap-select
#fi

### completion settings
setopt complete_aliases
setopt prompt_subst
#autoload -Uz vcs_info

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

function watch_pods()
{
    if [ $# -gt 0 ]; then
        watch kubectl get pods -n $1 -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase
    else
        watch kubectl get pods --all-namespaces -o=custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase
    fi
}

function generate_random_text()
{
    local length=$1
    curl -SsL 'https://qrng.anu.edu.au/API/jsonI.php?type=hex16&length=1&size='${length:-32}'' \
        | jq -rcM '.data[0]' \
        | tr -d '\n'
}

function generate_password()
{
    local length=$1
    openssl rand -hex ${length:-32} \
        | tr -d '\n'
}

function list_compute_instances()
{
    gcloud --project ${1:-cbclaims-dev2} compute instances list \
        --format='table(name, disks[0].licenses[0])'            \
        --filter='name !~ ".*gke.*"'                            \
        | awk 'sub(".*/", "", $2) { printf "%s:\t%s\n", $1, $2 }'
}

function docker_clean()
{
    docker images | tail -n +2 | awk '/<none>/ { print $3 }' | xargs docker rmi
}

function kubectx()
{
    kubectl config get-contexts | fzf | awk '{print $1}' | xargs kubectl config use-context
}

function view_path()
{
    echo $PATH | sed 's/:/\n/g'
}

## kitty specific stuff
if [ ${TERM} = 'xterm-kitty' ]; then
    alias icat='kitty +kitten icat'

    kitty + complete setup zsh | source /dev/stdin
fi

#zprof

alias luamake=/Users/aleciverson/Code/lsps/lua-language-server/3rd/luamake/luamake
