################################################################################
##
## Flight Starter
## Copyright (c) 2019-present Alces Flight Ltd
##
################################################################################
if ( ! $?flight_ROOT ) then
  setenv flight_ROOT /opt/flight
endif
setenv flight_ENV_root "${flight_ROOT}/opt/flight-env"
