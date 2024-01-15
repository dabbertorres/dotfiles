# zmodload zsh/zprof

if [[ $(uname) == "Linux" ]]; then
    IS_LINUX=true

    if [[ $(uname -a | grep "microsoft") ]]; then
        IS_WSL=true
    fi
elif [[ $(uname) == "Darwin" ]]; then
    IS_OSX=true
    if [ "${commands[brew]}" ]; then
        BREW_PREFIX=$(brew --prefix)
    fi
fi

export HISTFILE=${HOME}/.histfile
export HISTSIZE=10000
export SAVEHIST=10000

setopt \
    complete_aliases \
    inc_append_history \
    hist_expire_dups_first \
    hist_find_no_dups \
    hist_ignore_dups \
    hist_ignore_all_dups \
    hist_ignore_space \
    hist_save_no_dups \
    hist_reduce_blanks \
    hist_verify \
    nomatch \
    notify \
    prompt_subst

unsetopt \
    beep \
    extended_glob

zstyle :compinstall filename "${HOME}/.zshrc"

export KEYTIMEOUT=1 # https://zsh.sourceforge.io/Doc/Release/Parameters.html#:~:text=set%20to%20empty.-,KEYTIMEOUT,-The%20time%20the

function prepend_to_path()
{
    if [ -d "$1" ]; then
        export PATH="$1:${PATH}"
    fi
}

prepend_to_path "${HOME}/.local/bin"
prepend_to_path "/usr/local/bin"
prepend_to_path "/usr/local/sbin"

if [ ${IS_LINUX} ]; then
    prepend_to_path "/usr/local/go/bin:${PATH}"
elif [ ${IS_OSX} ]; then
    # export HOMEBREW_NO_AUTO_UPDATE=1

    if [ -n "${BREW_PREFIX}" ]; then
        prepend_to_path "${BREW_PREFIX}/opt/llvm/bin"
        prepend_to_path "${BREW_PREFIX}/opt/gcc/bin"
        prepend_to_path "${BREW_PREFIX}/opt/make/libexec/gnubin"
        prepend_to_path "${BREW_PREFIX}/opt/openssl/bin"
        prepend_to_path "${BREW_PREFIX}/opt/ruby/bin"
        prepend_to_path "${BREW_PREFIX}/opt/ruby/lib/ruby/gems/3.1.0/gems/rubocop-1.35.0/exe"
        prepend_to_path "${BREW_PREFIX}/opt/ruby/lib/ruby/gems/3.1.0/gems/sorbet-0.5.10324/bin"
    fi

    # prepend_to_path "${HOME}/Library/Python/3.10/bin"
    # alias lldb='PATH=/usr/bin lldb' # force using system python for lldb - avoids a python import error
    prepend_to_path "/usr/local/go/bin"
fi

if [ -f "${HOME}/.cargo/env" ]; then
    source "${HOME}/.cargo/env"
fi

autoload -Uz compinit

if [[ -n ${HOME}/.zcompdump(N.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# autoload -U +X bashcompinit && bashcompinit

if [ -d "${HOME}/.zsh/completion" ]; then
    fpath=(${HOME}/.zsh/completion ${fpath[@]})
fi

if [ "${commands[dotnet]}" ]; then
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    prepend_to_path "${HOME}/.dotnet/tools"
fi

if [ "${commands[gcloud]}" ]; then
    export CLOUDSDK_PYTHON_SITEPACKAGES=1
    if [ ${IS_OSX} ]; then
        source "${BREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
        source "${BREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
    fi

    function list_compute_instances()
    {
        gcloud --project "${1:-cbclaims-dev2}" compute instances list \
            --format='table(name, disks[0].licenses[0])'              \
            --filter='name !~ ".*gke.*"'                              \
            | awk 'sub(".*/", "", $2) { printf "%s:\t%s\n", $1, $2 }'
    }
fi

if [ ! "${commands[go]}" ] && [ -d "/usr/local/go" ]; then
    prepend_to_path "/usr/local/go/bin"
fi

if [ "${commands[go]}" ]; then
    export GOPATH="${HOME}/Code/Go"
    prepend_to_path "${GOPATH}/bin"
fi

if [ "${commands[java]}" ]; then
    if [ ${IS_OSX} ]; then
        # export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
    fi

    export _JAVA_AWT_WM_NONREPARENTING=1
    # prepend_to_path "$JAVA_HOME/bin"
fi

if [ "${commands[jq]}" ]; then
    # colon separated list (effect;color:...), in this order:
    # * null
    # * false
    # * true
    # * numbers
    # * strings
    # * arrays
    # * objects
    # see `man jq`
    export JQ_COLORS="1;31:0;35:0;35:0;33:0;32:1;39:1;39"
fi

if [ "${commands[kubectl]}" ]; then
    if [ "${commands[kubectl-krew]}" ]; then
        if [ ! -f "${fpath[1]}/_kubectl_krew" ]; then
            kubectl krew completion zsh > "${fpath[1]}/_kubectl_krew"
        fi
        prepend_to_path "${HOME}/.krew/bin"
    fi

    function watch_pods()
    {
        if [ $# -gt 0 ]; then
            watch kubectl get pods -n $1 -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase
        else
            watch kubectl get pods --all-namespaces -o=custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase
        fi
    }

    function kubectx()
    {
        kubectl config get-contexts | fzf | awk '{ print $1 }' | xargs kubectl config use-context
    }
fi

# neovim version manager (https://github.com/MordechaiHadad/bob)
if [ "${commands[bob]}" ]; then
    export PATH="${HOME}/.local/share/bob/nvim-bin:${PATH}"
fi

if [ "${commands[nvim]}" ]; then
    export EDITOR=nvim
    export VISUAL=nvim
    export NVIM_TUI_ENABLE_TRUE_COLOR=1 # Neovim true color support
    alias vim=nvim
fi

if [ "${commands[poetry]}" ] && [ ! -f "${fpath[1]}/_poetry" ]; then
    poetry completions zsh > "${fpath[1]}/_poetry"
fi

if [ "${commands[terraform]}" ] && [ ! -f "${fpath[1]}/_terraform" ]; then
    complete -o nospace -C "${commands[terraform]}" terraform
fi

if [ "${commands[upterm]}" ] && [ ! -f "${fpath[1]}/_upterm" ]; then
    upterm completion zsh > "${fpath[1]}/_upterm"
fi

if [ "${commands[vagrant]}" ]; then
    if [ ${IS_LINUX} ]; then
        true
    elif [ ${IS_OSX} ]; then
        fpath=(/opt/vagrant/embedded/gems/2.2.14/gems/vagrant-2.2.14/contrib/zsh ${fpath[@]})
    fi
fi

if [ "${commands[yarn]}" ]; then
    prepend_to_path "${HOME}/.yarn/bin"
    prepend_to_path "${HOME}/.config/yarn/global/node_modules/.bin"
fi

# fancy completion
if [ -d "${HOME}/.local/share/zsh-autosuggestions" ]; then
    source "${HOME}/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [ -d "/usr/local/share/zsh-autosuggestions" ]; then
    source "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ ${IS_OSX} ]; then
    if [ -d "${BREW_PREFIX}/opt/gitstatus" ]; then
        source "${BREW_PREFIX}/opt/gitstatus/gitstatus.prompt.zsh"
    fi
elif [ -d "${HOME}/.local/share/gitstatus" ]; then
    source "${HOME}/.local/share/gitstatus/gitstatus.prompt.zsh"
fi

# OSX specific settings for using non-default compiler toolchains
if [[ ${IS_OSX} ]]; then
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BREW_PREFIX}/lib"
    export TOOLCHAINS=swift

    # Use clang from Homebrew
    export CC="${BREW_PREFIX}/opt/llvm/bin/clang"
    export CXX="${BREW_PREFIX}/opt/llvm/bin/clang++"

    # Since I want to use Homebrew Clang, I have to specify where the system root is, for finding system headers and libraries.
    # In order for Go to be able to compile C code, I need to set a few of its CGO_* env vars for it to work properly.
    export CGO_CFLAGS="$(go env CGO_CFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
    export CGO_CPPFLAGS="$(go env CGO_CPPFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
    export CGO_CXXFLAGS="$(go env CGO_CXXFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
    export CGO_FFLAGS="$(go env CGO_FFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/"
    export CGO_LDFLAGS="$(go env CGO_LDFLAGS) -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/ -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
elif [[ ${IS_WSL} ]]; then
    export DISPLAY=$(awk '/nameserver/ { print $2 }' < /etc/resolv.conf):0.0
fi

### aliases

alias cl=clear
if [[ ${IS_OSX} ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias grep='grep --color=auto'

LUAMAKE_DIR="${HOME}/Code/lsps/lua-language-server/3rd/luamake"
if [ -d "${LUAMAKE_DIR}" ]; then
    alias luamake="${LUAMAKE_DIR}/luamake"
fi

### prompt functions

function show-pwd()
{
    echo " %F{green}%~%f"
}

function show-git-status()
{
    gitstatus_prompt_update
    if [[ ${GITSTATUS_PROMPT_LEN} -gt 0 ]]; then
        printf " (%s)" "${GITSTATUS_PROMPT}"
    fi
}

function show-jobs()
{
    read num_jobs < <(jobs -d | wc -l | xargs printf "%d / 2\n" | bc)
    if [[ num_jobs -gt 0 ]]; then
        printf " %%F{cyan}[%d job(s)]%%f" "${num_jobs}"
    fi
}

function show-dirs()
{
    local num_dirs=$(( $(dirs | sed -e 's/ /\n/g' | wc -l) - 1))
    if [[ ${num_dirs} -gt 0 ]]; then
        printf " %%F{magenta}[%d dir(s)]%%f" ${num_dirs}
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
    read job_sts < <(show-jobs)
    job_sts="${job_sts:+ $job_sts}"
    PROMPT="%U%n@%m%u$(show-pwd)$(show-git-status)$(show-pyvenv)${job_sts}$(show-dirs)
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

### misc functions

function generate_password()
{
    local length=$1
    openssl rand -base64 "${length:-32}" \
        | tr -d '\n'
}

if [ "${commands[docker]}" ]; then
    function docker_clean()
    {
        docker images | tail -n +2 | awk '/<none>/ { print $3 }' | xargs docker rmi
    }
fi

function view_path()
{
    echo "${PATH}" | sed 's/:/\n/g'
}

## kitty specific stuff
if [[ "${TERM}" == 'xterm-kitty' ]]; then
    alias icat='kitty +kitten icat'

    kitty + complete setup zsh | source /dev/stdin

    ### key bindings
    bindkey "\001" beginning-of-line
    bindkey "\005" end-of-line
    bindkey "\eOH" beginning-of-line
    bindkey "\eOF" end-of-line
    bindkey "\e[1;5D" backward-word
    bindkey "\e[1;5C" forward-word
    bindkey "\^[3~" delete-char
fi

bindkey -v

# match current input to history (up and down arrows)
# bindkey '^[[A' history-beginning-search-backward
# bindkey '^[[B' history-beginning-search-forward

# zprof
