#!/usr/bin/env bash
# Fuzzy-selects a cluster node via knav and opens a shell into it using ops-toolbelt.

set -e

[[ ! $(command -v fzf) ]] && echo "Error: You need to have fzf installed" >&2 && return 1

_SCRIPT_NAME="${0##*/}"
_SCRIPT_DIR=$( dirname "$( readlink -f -- "${0}" )" )
_PROJECT_DIR="${_SCRIPT_DIR}/.."

# Main entrypoint
function _main() {
    local _target="$(knav get nodes | \
        tail -n +2 | \
        awk '{print $1}' | \
        fzf --tac)"
    if [[ -z "${_target}" ]]; then
      exit 1
    fi

    knav node-shell "${_target}" \
        -n kube-system \
        --image europe-docker.pkg.dev/sap-se-gcp-k8s-delivery/releases-public/europe-docker_pkg_dev/gardener-project/releases/gardener/ops-toolbelt
}

_main "$@"
