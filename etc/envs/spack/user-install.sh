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

env_stage "Verifying prerequisites"
if [ ! -f spack-v0.14.1.tar.gz ]; then
  env_stage "Fetching prerequisite (spack)"
  wget https://github.com/spack/spack/archive/v0.14.1.tar.gz -O spack-v0.14.1.tar.gz
fi

mkdir -p ${flight_ENV_ROOT}/spack+${name}
env_stage "Extracting Spack hierarchy (spack@${name})"
tar -C ${flight_ENV_ROOT}/spack+${name} -xzf spack-v0.14.1.tar.gz --strip-components=1
cd ${flight_ENV_ROOT}/spack+${name}
env_stage "Bootstrapping Spack environment (spack@${name})"
if ! which python &>/dev/null; then
  sed -i -e 's,#!/usr/bin/env python$,#!/usr/bin/env python3,g' bin/spack
fi
bin/spack bootstrap
