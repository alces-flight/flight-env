#!/bin/bash
sourced=0
if [ -n "$ZSH_EVAL_CONTEXT" ]; then
  case $ZSH_EVAL_CONTEXT in *:file) sourced=1;; esac
elif [ -n "$KSH_VERSION" ]; then
  [ "$(cd $(dirname -- $0) && pwd -P)/$(basename -- $0)" != "$(cd $(dirname -- ${.sh.file}) && pwd -P)/$(basename -- ${.sh.file})" ] && sourced=1
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && sourced=1
else # All other shells: examine $0 for known shell binary filenames
  # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|dash) sourced=1;; esac
fi

flenv() {
  local op tmpf rc flight_ENV_eval
  export FLIGHT_PROGRAM_NAME=flenv
  op="$1"
  case $op in
    activate|deactivate|switch)
      tmpf=$(mktemp -t flenv.XXXXXXXX)
      flight_ENV_eval=true $flight_ENV_root/bin/env "$@" > $tmpf
      rc=$?
      if [ $rc -gt 0 ]; then
        cat $tmpf
        unset FLIGHT_PROGRAM_NAME
        return $rc
      else
        source $tmpf
      fi
      rm -f $tmpf
      ;;
    *)
      $flight_ENV_root/bin/env "$@"
      ;;
  esac
  unset FLIGHT_PROGRAM_NAME
}

if [ $sourced == 1 ]; then
  unset sourced
  export flight_ENV_root=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
else
  echo "$0: this script should be sourced, not executed"
  exit 1
fi
