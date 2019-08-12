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
set -e

flight_ENV_ROOT=${flight_ENV_ROOT:-$HOME/.local/share/flight/env}
flight_ENV_CACHE=${flight_ENV_CACHE:-$HOME/.cache/flight/env}
name=$1

if [ -z "$name" ]; then
  echo "error: environment name not supplied"
  exit 1
fi

# create build area
mkdir -p ${flight_ENV_CACHE}/build
cd ${flight_ENV_CACHE}/build

env_stage "Verifying prerequisites"
if [ ! -d "${flight_ENV_ROOT}"/share/modules/4.3.0 ]; then
  if [ ! -d ${flight_ENV_ROOT}/share/tcl/8.6.9 ]; then
    if [ ! -f tcl8.6.9-src.tar.gz ]; then
      env_stage "Fetching prerequisite (tcl)"
      wget https://prdownloads.sourceforge.net/tcl/tcl8.6.9-src.tar.gz
    fi
    env_stage "Extracting prerequisite (tcl)"
    tar xzf tcl8.6.9-src.tar.gz
    env_stage "Building prerequisite (tcl)"
    cd tcl8.6.9/unix
    ./configure --prefix=${flight_ENV_ROOT}/share/tcl/8.6.9
    make
    env_stage "Installing prerequisite (tcl)"
    make install
    ln -s ${flight_ENV_ROOT}/share/tcl/8.6.9/bin/tclsh8.6 ${flight_ENV_ROOT}/share/tcl/8.6.9/bin/tclsh
    cd ../..
  fi
  tcl_params="--with-tcl=${flight_ENV_ROOT}/share/tcl/8.6.9/lib --with-tclsh=${flight_ENV_ROOT}/share/tcl/8.6.9/bin/tclsh --with-tcl-ver=8.6 --without-tclx"
  if [ ! -f modules-4.3.0.tar.gz ]; then
    env_stage "Fetching prerequisite (modules)"
    wget https://sourceforge.net/projects/modules/files/Modules/modules-4.3.0/modules-4.3.0.tar.gz
  fi
  env_stage "Extracting prerequisite (modules)"
  tar xzf modules-4.3.0.tar.gz
  env_stage "Building prerequisite (modules)"
  cd modules-4.3.0
  ./configure \
          --disable-versioning \
          --prefix=${flight_ENV_ROOT}/share/modules/4.3.0 $tcl_params
  make
  env_stage "Installing prerequisite (modules)"
  make install
fi

env_stage "Creating environment (modules@${name})"

mkdir -p ${flight_ENV_ROOT}/modules+${name}/modulefiles
cp ${flight_ENV_ROOT}/share/modules/4.3.0/modulefiles/null ${flight_ENV_ROOT}/modules+${name}/modulefiles
cat <<EOF > ${flight_ENV_ROOT}/modules+${name}/modules.bash.rc
module use ${flight_ENV_ROOT}/modules+${name}/modulefiles
EOF
