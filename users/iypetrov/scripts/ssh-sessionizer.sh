#!/usr/bin/env bash

[[ ! $(command -v fzf) ]] && echo "Error: You need to have fzf installed" >&2 && return 1

target="$(knav get nodes | tail -n +2 | awk '{print $1}' | fzf --tac)"
if [[ -z "${target}" ]]; then
  exit 1
fi

knav node-shell "${target}" -n kube-system --image europe-docker.pkg.dev/sap-se-gcp-k8s-delivery/releases-public/europe-docker_pkg_dev/gardener-project/releases/gardener/ops-toolbelt
