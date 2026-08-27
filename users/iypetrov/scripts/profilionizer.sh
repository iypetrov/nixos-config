#!/usr/bin/env bash

[[ ! $(command -v fzf) ]] && echo "Error: You need to have fzf installed" >&2 && return 1
[[ ! $(command -v kubectx) ]] && echo "Error: You need to have kubectx installed" >&2 && return 1

targets="$(echo "kubens kubectx knav" | tr ' ' '\n' | fzf --tac)"
if [[ -z "${targets}" ]]; then
  exit 1
fi

case "${targets}" in
  "kubens")
    export KUBECONFIG="$(realpath "$(yq -r '.current as $c | .targets[] | select(.name == $c) | .kubeconfigPath' ~/.config/knav/config.yaml | sed "s|^~|$HOME|")")"
    kubens
    ;;
  "kubectx")
    export KUBECONFIG="$(realpath "$(yq -r '.current as $c | .targets[] | select(.name == $c) | .kubeconfigPath' ~/.config/knav/config.yaml | sed "s|^~|$HOME|")")"
    kubectx
    ;;
  "knav")
    knav
    ;;
  *)
    echo "Something went wrong" >&2
    ;;
esac
