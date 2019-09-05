################################################################################
##
## Flight Environment
## Copyright (c) 2019-present Alces Flight Ltd
##
################################################################################
if ( -f ${flight_ROOT}/etc/flight-env.cshrc ) then
  source ${flight_ROOT}/etc/flight-env.cshrc
endif
if ( ! $?flight_ENV_root ) then
   setenv flight_ENV_root "${flight_ROOT}"/opt/flight-env
endif
setenv flight_ENV_shell tcsh

set sourcechk=1
source ${flight_ENV_root}/etc/tcsh/flenv-fnwrapper.csh
unset sourcechk

set flight_ENV_cmd="${flight_ROOT}/bin/flexec ruby $flight_ENV_root/bin/flenv"

if ( ! $?flight_ENV_active ) then
  # Activate default environment
  set flight_ENV_default=`flenv show-default --empty-if-unset`
  if ( "$flight_ENV_default" != "" ) then
    flenv activate "${flight_ENV_default}"
  endif
  unset flight_ENV_default
endif
