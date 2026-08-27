#!/usr/bin/env bash

[[ ! $(command -v fzf) ]] && echo "Error: You need to have fzf installed" >&2 && return 1

prj_dir="$HOME/Projects"

target="$(find "$prj_dir" -mindepth 2 -maxdepth 2 -type d -print | sed "s|$prj_dir/||" | fzf)"
if [[ -z "${target}" ]]; then
    exit 0
fi

curr_session="$(echo "${target}" | tr '.' '_')"

tmux_running="$(pgrep tmux)"
if [[ -z "$TMUX" ]] && [[ -z "${tmux_running}" ]]; then
    tmux new-session -s "${curr_session}" -c "${prj_dir}/${target}" "vim ${prj_dir}/${target}; $SHELL"
    tmux new-window -t "${curr_session}:2" -c "${prj_dir}/${target}"
    tmux select-window -t "${curr_session}:1"
fi

if ! tmux has-session -t="${curr_session}" 2> /dev/null; then
    repo_name="$(basename "${target}")"
    gh repo sync "iypetrov/${repo_name}" 2>/dev/null || true

    tmux new-session -ds "${curr_session}" -c "${prj_dir}/${target}" "vim ${prj_dir}/${target}; $SHELL"
    tmux new-window -t "${curr_session}:2" -c "${prj_dir}/${target}"
    tmux select-window -t "${curr_session}:1"
fi

tmux switch-client -t "${curr_session}"
