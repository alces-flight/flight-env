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

flight_ENV_ROOT=${flight_ENV_ROOT:-/opt/flight/var/lib/env}
flight_ENV_CACHE=${flight_ENV_CACHE:-/opt/flight/var/cache/env/build}
name=$1

if [ -z "$name" ]; then
  echo "error: environment name not supplied"
  exit 1
fi

# create build area
mkdir -p ${flight_ENV_CACHE}/build
cd ${flight_ENV_CACHE}/build

# XXX - verify that /proc/sys/user/max_user_namespaces is greater than 0

if [ ! -f squashfs4.3.tar.gz ]; then
  wget https://sourceforge.net/projects/squashfs/files/squashfs/squashfs4.3/squashfs4.3.tar.gz
  tar xzf squashfs4.3.tar.gz
  cd squashfs4.3/squashfs-tools
  make
  mkdir -p ${flight_ENV_ROOT}/share/squashfs/4.3/bin
  mv mksquashfs unsquashfs ${flight_ENV_ROOT}/share/squashfs/4.3/bin
  cd ../..
fi

if [ ! -f go1.11.linux-amd64.tar.gz ]; then
  wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
  tar xzf go1.11.linux-amd64.tar.gz
fi

if [ ! -f singularity-3.2.1.tar.gz ]; then
  wget https://github.com/sylabs/singularity/archive/v3.2.1.tar.gz -O singularity-3.2.1.tar.gz
  export GOPATH=${flight_ENV_CACHE}/build/go
  export PATH=${GOPATH}/bin:$PATH
  mkdir -p $GOPATH/src/github.com/sylabs
  cd $GOPATH/src/github.com/sylabs
  tar xzf ${flight_ENV_CACHE}/build/singularity-3.2.1.tar.gz
  mv singularity-3.2.1 singularity
  cd singularity
  echo '3.2.1' >> VERSION
  ./mconfig --without-suid --prefix=${flight_ENV_ROOT}/share/singularity/3.2.1
  cd builddir
  make
  make install
  sed -e "s,# mksquashfs path =.*,mksquashfs path = ${flight_ENV_ROOT}/share/squashfs/4.3/bin/mksquashfs,g" \
      -i "${flight_ENV_ROOT}"/share/singularity/3.2.1/etc/singularity/singularity.conf
fi

mkdir -p ${flight_ENV_ROOT}/singlarity+<%= env_name %>
