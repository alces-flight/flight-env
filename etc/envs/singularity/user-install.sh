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
# https://github.com/openflighthpc/flight-env
# ==============================================================================
set -e

flight_ENV_ROOT=${flight_ENV_ROOT:-$HOME/.local/share/flight/env}
flight_ENV_CACHE=${flight_ENV_CACHE:-$HOME/.cache/flight/env}
flight_ENV_BUILD_CACHE=${flight_ENV_BUILD_CACHE:-$HOME/.cache/flight/env/build}
name=$1

if [ -z "$name" ]; then
  echo "error: environment name not supplied"
  exit 1
fi

# create directory structure
mkdir -p ${flight_ENV_CACHE} ${flight_ENV_BUILD_CACHE} ${flight_ENV_ROOT}
cd ${flight_ENV_BUILD_CACHE}

# XXX - verify that /proc/sys/user/max_user_namespaces is greater than 0

env_stage "Verifying prerequisites"
if [ ! -f squashfs4.4.tar.gz ]; then
  env_stage "Fetching prerequisite (squashfs)"
  wget https://sourceforge.net/projects/squashfs/files/squashfs/squashfs4.4/squashfs4.4.tar.gz
  env_stage "Extracting prerequisite (squashfs)"
  tar xzf squashfs4.4.tar.gz
  env_stage "Building prerequisite (squashfs)"
  cd squashfs4.4/squashfs-tools
  make
  env_stage "Installing prerequisite (squashfs)"
  mkdir -p ${flight_ENV_ROOT}/share/squashfs/4.4/bin
  mv mksquashfs unsquashfs ${flight_ENV_ROOT}/share/squashfs/4.4/bin
  cd ../..
fi

if [ ! -f go1.11.linux-amd64.tar.gz ]; then
  env_stage "Fetching prerequisite (go)"
  wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
  env_stage "Extracting prerequisite (go)"
  tar xzf go1.11.linux-amd64.tar.gz
fi

if [ ! -f singularity-3.2.1.tar.gz ]; then
  env_stage "Fetching prerequisite (singularity)"
  wget https://github.com/sylabs/singularity/archive/v3.2.1.tar.gz -O singularity-3.2.1.tar.gz
  export GOPATH=${flight_ENV_CACHE}/build/go
  export PATH=${GOPATH}/bin:$PATH
  mkdir -p $GOPATH/src/github.com/sylabs
  cd $GOPATH/src/github.com/sylabs
  env_stage "Extracting prerequisite (singularity)"
  tar xzf ${flight_ENV_CACHE}/build/singularity-3.2.1.tar.gz
  mv singularity-3.2.1 singularity
  cd singularity
  echo '3.2.1' >> VERSION
  env_stage "Building prerequisite (singularity)"
  if [ "$UID" == "0" ]; then
    ./mconfig --prefix=${flight_ENV_ROOT}/share/singularity/3.2.1
  else
    ./mconfig --without-suid --prefix=${flight_ENV_ROOT}/share/singularity/3.2.1
  fi
  cd builddir
  make
  env_stage "Installing prerequisite (singularity)"
  make install
  sed -e "s,# mksquashfs path =.*,mksquashfs path = ${flight_ENV_ROOT}/share/squashfs/4.4/bin/mksquashfs,g" \
      -i "${flight_ENV_ROOT}"/share/singularity/3.2.1/etc/singularity/singularity.conf
fi

env_stage "Creating environment (singularity@${name})"
mkdir -p "${flight_ENV_ROOT}/singularity+${name}"
