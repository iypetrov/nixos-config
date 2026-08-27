#!/usr/bin/env bash

set -e

[[ ! $( command -v xrandr ) ]] && echo "Error: You need to have xrandr installed" >&2 && exit 1

_SCRIPT_NAME="${0##*/}"
_SCRIPT_DIR=$( dirname "$( readlink -f -- "${0}" )" )
_PROJECT_DIR="${_SCRIPT_DIR}/.."
_RESOLUTION="$( xrandr | grep -E " \+$" | xargs | cut -d ' ' -f 1 )"

# Main entrypoint
function _main() {
    xrandr --output Virtual-1 --mode "${_RESOLUTION}"
}

_main "$@"
