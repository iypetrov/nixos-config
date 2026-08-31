#!/usr/bin/env bash
# Presents a menu to switch between Kubernetes namespaces, contexts, or kubeconfigs.

set -e

[[ ! $(command -v fzf) ]] && echo "Error: You need to have fzf installed" >&2 && return 1
[[ ! $(command -v kubectx) ]] && echo "Error: You need to have kubectx installed" >&2 && return 1
[[ ! $(command -v whiptail) ]] && echo "Error: You need to have whiptail installed" >&2 && return 1

_SCRIPT_NAME="${0##*/}"
_SCRIPT_DIR=$( dirname "$( readlink -f -- "${0}" )" )
_PROJECT_DIR="${_SCRIPT_DIR}/.."

# Main entrypoint
function _main() {
    local _target="$(whiptail --title "Kubernetes Navigator" \
        --menu "What would you like to switch?" 14 60 3 \
        "kubens" "namespaces" \
        "kubectx" "clusters/contexts" \
        "knav" "kubeconfigs" \
        3>&1 1>&2 2>&3)"
    if [[ -z "${_target}" ]]; then
      exit 1
    fi

    case "${_target}" in
      "kubens")
        kubens
        ;;
      "kubectx")
        kubectx
        ;;
      "knav")
        knav
        ;;
      *)
        echo "Something went wrong" >&2
        ;;
    esac
}

_main "$@"
