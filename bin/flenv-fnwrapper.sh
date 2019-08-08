#!/bin/bash
# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Environment.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Environment is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Environment. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Environment, please visit:
# https://github.com/alces-flight/flight-env
# ==============================================================================
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
      flight_ENV_eval=true $flight_ENV_root/bin/flenv "$@" > $tmpf
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
      $flight_ENV_root/bin/flenv "$@"
      ;;
  esac
  unset FLIGHT_PROGRAM_NAME
}

export FLIGHT_ENV_EVAL_CMD='flenv %s'

if [ $sourced == 1 ]; then
  unset sourced
  export flight_ENV_root=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
else
  echo "$0: this script should be sourced, not executed"
  exit 1
fi
