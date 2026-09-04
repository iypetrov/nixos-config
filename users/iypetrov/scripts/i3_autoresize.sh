#!/usr/bin/env bash
# Sets the i3 display resolution to match the currently active xrandr output mode.

set -e

[[ ! $( command -v xrandr ) ]] && echo "Error: You need to have xrandr installed" >&2 && exit 1

_SCRIPT_NAME="${0##*/}"
_SCRIPT_DIR=$( dirname "$( readlink -f -- "${0}" )" )
_PROJECT_DIR="${_SCRIPT_DIR}/.."

# Main entrypoint
function _main() {
    local _resolution="$( xrandr | grep -E " \+$" | xargs | cut -d ' ' -f 1 )"
    xrandr --output Virtual-1 --mode "${_resolution}"
}

_main "$@"
