#!/usr/bin/env bash

set -e

[[ ! $(command -v tmux) ]] && echo "Error: You need to have tmux installed" >&2 && return 1

_SCRIPT_NAME="${0##*/}"
_SCRIPT_DIR=$( dirname "$( readlink -f -- "${0}" )" )
_PROJECT_DIR="${_SCRIPT_DIR}/.."

# Main entrypoint
function _main() {
    local _target="$(tmux list-sessions \
        -F '#{session_last_attached} #{session_name} #{session_attached}' | \
        awk '$3 == 0 && $2 !~ /^[0-9]+$/ {print $1, $2}' | \
        sort -rn | \
        cut -d' ' -f2- | \
        fzf)"
    if [[ -z "${_target}" ]]; then
        exit 0
    fi

    tmux switch-client -t "${_target}"
}

_main "$@"
