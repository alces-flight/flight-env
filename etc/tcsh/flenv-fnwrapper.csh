#!/bin/tcsh
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
if ($?tcsh) then
  setenv flight_ENV_shell tcsh
else
  setenv flight_ENV_shell csh
endif

set prefix=""
set postfix=""

if ( $?histchars ) then
  set histchar = `echo $histchars | cut -c1`
  set _histchars = $histchars

  set prefix  = 'unset histchars;'
  set postfix = 'set histchars = $_histchars;'
else
  set histchar = \!
endif

if ($?noglob) then
  set prefix  = "$prefix""set noglob;"
  set postfix = "$postfix""unset noglob;"
endif

set postfix = "set _exit="'$status'"; $postfix; test 0 = "'$_exit;'

if (! $?sourcechk) then
  set sourcechk=($_)
  if ( "$sourcechk" == "" ) then
    echo "${0}: this script should be sourced, not executed"
    exit 1
  endif
endif
if (! $?flight_ENV_root) then
  set dirname=`dirname $sourcechk[2]`
  setenv flight_ENV_root `cd $dirname/../.. && pwd`
  unset dirname
endif
unset sourcechk

alias flenv $prefix'set args="'$histchar'*";source '$flight_ENV_root'/etc/tcsh/flenv.tcsh; '$postfix;
unset prefix
unset postfix

setenv flight_ENV_eval_cmd 'flenv %s'
