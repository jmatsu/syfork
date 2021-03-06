#!/usr/bin/env bash

set -e

_MY_NAME=$(basename $0)
_MY_VERSION='0.1'
_DEFAULT_ARGS="$@"

is_pipe() {
    if [ -p /dev/stdin ]; then
        return 0
    else
        return 1
    fi
}

show_usage() {
    show_my_profile
    show_options
}

show_my_profile() {
    echo "Usage: ${_MY_NAME} [OPTIONS] ARGS"
    echo "  Easy to synchronize forked repository with super repository."
    echo "-----------------------"
}

show_options() {
    echo "Available options:"
    echo "  -h, --help"
    echo "      --version"
    echo "  -r, --remote # remote name for your repository"
    echo "  -s, --super # remote name for super repository"
    echo "-----------------------"
}

show_version() {
    echo "${_MY_VERSION}"
}

is_forked() {
    curl -sL $1 | grep "forked from" | sed -e 's/.*<a .*">//g' -e 's/<\/a>.*//g' 2>/dev/null
}

get_repository_url() {
    git config --get remote.$1.url | sed -e 's/^git@github.com:/https:\/\/github\.com\//'
}

has_repository_url() {
    git config --get remote.$1.url 1> /dev/null
}

find_forked() {
    cd ${_PWD}

    if [ -d "$1" ]; then
        _REPO_PATH="$1"
    else
        _REPO_PATH="${_PWD%/}/$1"
    fi

    cd "${_REPO_PATH}"

    if has_repository_url "${_SUPER}"; then
        git fetch "${_SUPER}"
    elif has_repository_url "${_REMOTE}"; then
        if _SUPER_REPO=`is_forked $(get_repository_url "${_REMOTE}")`; then
            git remote add "${_SUPER}" "git@github.com:${_SUPER_REPO}"
            git fetch "${_SUPER}"
        else
            echo "${_MY_NAME}: Not forked repository. - '$1'"
        fi
    else
        echo "${_MY_NAME}: Remote not found. skip. - '${_REMOTE} on $1'"
    fi
}

function assert_if_needs_one() {
  if [ -z "$2" ] || [[ "$2" =~ ^-.* ]]; then
      echo "${_MY_NAME}: '$1' requires one argument" > /dev/stderr
      exit 1;
  fi
  _global_opt_flag=1
}

_PWD=`pwd`
_REMOTE="origin"
_SUPER="syfork"
_REPOS=()

unset _global_opt_flag

for OPT in "$@"
do
  [ ! -z "${_global_opt_flag:-}" ]&&{
    _global_opt_flag=
    shift 1
    continue
  }

  case "$OPT" in
      '-h'|'--help' )
          show_usage
          exit 0
          ;;
      '--version' )
          show_version
          exit 0
          ;;
      '-r'|'--remote' )
          assert_if_needs_one "$1" "${2:-}"
          _REMOTE="$2"
          ;;
      '-s'|'--super' )
          assert_if_needs_one "$1" "${2:-}"
          _SUPER="$2"
          ;;
      -*) # unregistered options
          _NOT_REGISTERED_OPTS="${_NOT_REGISTERED_OPTS} $1"
          ;;
      *) # arguments which is not option
          _REPOS+=( $1 )
          ;;
  esac

  shift 1
done

unset _global_opt_flag

# for xargs
export -f find_forked has_repository_url get_repository_url is_forked
export _PWD _REMOTE _MY_NAME _SUPER

echo "${_REPOS[@]}" | tr " " "\0\n" | xargs -I % -0 -n -1 bash -c "find_forked %"