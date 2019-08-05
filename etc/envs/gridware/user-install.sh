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

if [ ! -f modules-3.2.10.tar.gz ]; then
  if ! which tclsh &>/dev/null; then
    if [ ! -d ${flight_ENV_ROOT}/share/tcl/8.6.9 ]; then
      if [ ! -f tcl8.6.9-src.tar.gz ]; then
        wget https://prdownloads.sourceforge.net/tcl/tcl8.6.9-src.tar.gz
        tar xzf tcl8.6.9-src.tar.gz
        cd tcl8.6.9/unix
        ./configure --prefix=${flight_ENV_ROOT}/share/tcl/8.6.9
        make
        make install
        ln -s ${flight_ENV_ROOT}/share/tcl/8.6.9/bin/tclsh8.6 ${flight_ENV_ROOT}/share/tcl/8.6.9/bin/tclsh
        cd ..
      fi
    fi
    tcl_params="--with-tcl=${flight_ENV_ROOT}/share/tcl/8.6.9/lib --with-tcl-ver=8.6 --without-tclx --with-tclx-ver=8.6"
  fi
  wget https://sourceforge.net/projects/modules/files/Modules/modules-3.2.10/modules-3.2.10.tar.gz
  tar xvf modules-3.2.10.tar.gz
  cd modules-3.2.10
  CPPFLAGS="-DUSE_INTERP_ERRORLINE" ./configure \
          --disable-versioning \
          --prefix=/home/vagrant/.local/share/flight/env/share/modules/3.2.10 $tcl_params
  make
  make install
  cd ..
  rm -f ${flight_ENV_ROOT}/share/modules/3.2.10/Modules/init/.modulespath
  touch ${flight_ENV_ROOT}/share/modules/3.2.10/Modules/init/.modulespath
fi

if [ ! -f gridware-2.0.0.tar.gz ]; then
  mkdir -p "${flight_ENV_ROOT}/share/gridware/2.0.0"
  # XXX
  cp -R /code/alces-flight/flight-gridware/* "${flight_ENV_ROOT}/share/gridware/2.0.0"
  
  cd ${flight_ENV_ROOT}/share/gridware/2.0.0
  /opt/flight/bin/flexec bundle install --path=vendor --without=development --without=test
fi

mkdir -p ${flight_ENV_ROOT}/gridware+default/etc/modules
cp ${flight_ENV_ROOT}/share/modules/3.2.10/Modules/modulefiles/null ${flight_ENV_ROOT}/gridware+default/etc/modules
