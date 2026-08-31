#!/usr/bin/env bash
# Fuzzy-selects a project directory and opens (or switches to) a tmux session for it.

set -e

[[ ! $(command -v fzf) ]] && echo "Error: You need to have fzf installed" >&2 && return 1

_SCRIPT_NAME="${0##*/}"
_SCRIPT_DIR=$( dirname "$( readlink -f -- "${0}" )" )
_PROJECT_DIR="${_SCRIPT_DIR}/.."

# Main entrypoint
function _main() {
    local _target="$(find "${XDG_PROJECTS_DIR}" \
        -mindepth 2 \
        -maxdepth 2 \
        -type d \
        -print | \
        sed "s|${XDG_PROJECTS_DIR}/||" | \
        fzf)"
    if [[ -z "${_target}" ]]; then
        exit 0
    fi

    local _curr_session="$(echo "${_target}" | tr '.' '_')"
    local _tmux_running="$(pgrep tmux)"
    if [[ -z "$TMUX" ]] && [[ -z "${_tmux_running}" ]]; then
        tmux new-session \
            -s "${_curr_session}" \
            -c "${XDG_PROJECTS_DIR}/${_target}" \
            "vim ${XDG_PROJECTS_DIR}/${_target}; $SHELL"
        tmux new-window \
            -t "${_curr_session}:2" \
            -c "${XDG_PROJECTS_DIR}/${_target}"
        tmux select-window -t "${_curr_session}:1"
    fi

    if ! tmux has-session -t="${_curr_session}" 2> /dev/null; then
        local _repo_name="$(basename "${_target}")"
        gh repo sync "iypetrov/${_repo_name}" 2>/dev/null || true

        tmux new-session \
            -ds "${_curr_session}" \
            -c "${XDG_PROJECTS_DIR}/${_target}" \
            "vim ${XDG_PROJECTS_DIR}/${_target}; $SHELL"
        tmux new-window \
            -t "${_curr_session}:2" \
            -c "${XDG_PROJECTS_DIR}/${_target}"
        tmux select-window -t "${_curr_session}:1"
    fi

    tmux switch-client -t "${_curr_session}"
}

_main "$@"
