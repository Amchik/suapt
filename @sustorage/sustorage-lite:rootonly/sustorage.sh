#!/bin/bash

unset SOCK_DEBUG
export SOCK_STDIN=1

_usage() {
  echo "[::sustorage-lite:rootonly] use _otps for check avalibe opts"
}

if [[ $# -lt 1 ]]; then
  _usage
  exit 1
fi

case "$1" in
  version)
    echo "1"
    ;;
  revision)
    echo "sustorage-lite:rootonly, default for sustoraged-rootonly"
    ;;
  _opts)
    echo "|version|revision|_opts|prompt|run|"
    ;;
  prompt)
    if [[ $# -lt 3 ]]; then
      echo "[::sustorage] sustorage prompt user command"
      exit 1
    fi
    user=$2
    if ! [[ "$user" = root ]]; then
      echo "[::sustorage-lite:rootonly] Only root allowed"
      exit 1
    fi
    cmd="${@:3}"
    export SOCK_STDIN=1
    pwd=$($XSUSTORAGEHELPER)
    if [[ $? -ne 0 ]]; then
      echo "[::sustorage] connection failed to sustoraged"
      exit 1
    fi
    printf '%s' "$pwd" | su -c "printf '\r'; $cmd"
    exit $?
    ;;
esac
