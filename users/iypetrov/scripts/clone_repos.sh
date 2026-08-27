#!/usr/bin/env bash

set -e

[[ ! $( command -v git ) ]] && echo "Error: You need to have git installed" >&2 && exit 1
[[ ! $( command -v gh ) ]] && echo "Error: You need to have gh installed" >&2 && exit 1
[[ ! $( command -v jq ) ]] && echo "Error: You need to have jq installed" >&2 && exit 1

_SCRIPT_NAME="${0##*/}"
_SCRIPT_DIR=$( dirname "$( readlink -f -- "${0}" )" )
_PROJECT_DIR="${_SCRIPT_DIR}/.."

function _clone_repo() {
    local _repo_url="$1"
    local _path="$2"
    local _repo="${_repo_url##*/}"
    _repo="${_repo%.git}"

    if [[ -d "${XDG_PROJECTS_DIR}/${_path}" ]]; then
        echo "🔕 ${_repo} was already cloned to ${XDG_PROJECTS_DIR}/${_path}"
        return 0
    else
        echo "🔧 Cloning ${_repo} to ${XDG_PROJECTS_DIR}/${_path}"
        if git clone "${_repo_url}" "${XDG_PROJECTS_DIR}/${_path}"; then
            echo "✅ ${_repo} cloned successfully to ${XDG_PROJECTS_DIR}/${_path}"
            return 0
        else
            echo "❌ Failed to clone ${_repo_url} to ${XDG_PROJECTS_DIR}/${_path}"
            return 1
        fi
    fi
}

# Build a remote URL for owner/repo using the given scheme + host.
function _build_remote_url() {
    local _scheme="$1"
    local _host="$2"
    local _owner_repo="$3"

    if [[ "${_scheme}" == "https" ]]; then
        echo "https://${_host}/${_owner_repo}.git"
    else
        echo "git@${_host}:${_owner_repo}.git"
    fi
}

function _clone_or_fork_repo() {
    local _repo_url="$1"
    local _path="$2"
    local _github_username="${3:-iypetrov}"

    local _scheme _host
    if [[ "${_repo_url}" == git@*:* ]]; then
        _scheme="ssh"
        _host="${_repo_url#git@}"
        _host="${_host%%:*}"
    elif [[ "${_repo_url}" == https://* ]]; then
        _scheme="https"
        _host="${_repo_url#https://}"
        _host="${_host%%/*}"
    else
        _scheme="ssh"
        _host="github.com"
    fi

    # upstream = owner/repo (strip the git@host:/https://host/ prefix and .git suffix).
    local _upstream="${_repo_url#*@}"      # drop leading git@ if present
    _upstream="${_upstream#*://}"          # drop scheme:// if present
    _upstream="${_upstream#"${_host}"}"    # drop the host
    _upstream="${_upstream#[:/]}"          # drop the leading : or /
    _upstream="${_upstream%.git}"          # drop trailing .git
    local _repo_name="${_upstream##*/}"
    local _fork_url="$( _build_remote_url "${_scheme}" "${_host}" "${_github_username}/${_repo_name}" )"

    if [[ -d "${XDG_PROJECTS_DIR}/${_path}" ]]; then
        echo "🔕 ${_upstream} was already cloned to ${XDG_PROJECTS_DIR}/${_path}"
        return 0
    fi

    if GH_HOST="${_host}" gh repo list "${_github_username}" --fork --json nameWithOwner,parent \
        | jq -e --arg target "${_upstream}" \
            '.[] | select("\(.parent.owner.login)/\(.parent.name)" == $target)' >/dev/null 2>&1; then
        echo "🔧 Fork exists for ${_upstream}"
    else
        echo "⚠️ No fork found for ${_upstream}, creating fork..."
        GH_HOST="${_host}" gh repo fork "${_upstream}" --clone=false
        echo "✅ Fork created for ${_upstream}"
    fi

    _clone_repo "${_fork_url}" "${_path}" || return 1
    git -C "${XDG_PROJECTS_DIR}/${_path}" remote add upstream \
        "$( _build_remote_url "${_scheme}" "${_host}" "${_upstream}" )" 2>/dev/null || true
    echo "🔄 Upstream set for ${_repo_name} -> ${_upstream}"
}

# Main entrypoint
function _main() {
    # common
    _clone_repo git@github.com:iypetrov/nixos-config.git common/nixos-config

    # personal
    _clone_repo git@github.com:iypetrov/go-playground.git personal/go-playground
    _clone_repo git@github.com:iypetrov/aws-playground.git personal/aws-playground
    _clone_repo git@github.com:iypetrov/k8s-playground.git personal/k8s-playground
}

_main "$@"
