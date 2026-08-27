#!/usr/bin/env bash

target="$(tmux list-sessions -F '#{session_last_attached} #{session_name} #{session_attached}' | awk '$3 == 0 && $2 !~ /^[0-9]+$/ {print $1, $2}' | sort -rn | cut -d' ' -f2- | fzf)"
if [[ -z "${target}" ]]; then
    exit 0
fi

tmux switch-client -t "${target}"
