#!/usr/bin/env sh

set -e

while [ $# -gt 0 ]; do
    case $1 in
        "--apply")
            APPLY=1
            shift
            ;;

        "--help")
            echo "dotfiles install.sh"
            echo ""
            echo "Installs dotfiles as symlinks in locations expected by applications."
            echo ""
            echo "Flags"
            echo ""
            echo "  --apply  Actually installs the symlinks. Without this flag, the script only prints what it would do."
            exit 1
            ;;

        *)
            echo "unknown flag: $1"
            exit 1
            ;;
    esac
done

if [ -n "${APPLY}" ]; then
    link()
    {
        ln -sf "$1" "$2"
    }
else
    link()
    {
        echo "ln -sf $1 $2"
    }
fi

DOTFILES_ROOT=$(readlink -f "$0" | xargs dirname)

CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}

link "${DOTFILES_ROOT}/zshrc" "${HOME}/.zshrc"
link "${DOTFILES_ROOT}/vimrc" "${HOME}/.vimrc"

for app in "${DOTFILES_ROOT}"/config/*; do
    app_dir="${CONFIG_HOME}/$(basename "${app}")"
    mkdir -p "${app_dir}"

    for file in "${app}"/*; do
        link "${file}" "${app_dir}/$(basename "${file}")"
    done
done
