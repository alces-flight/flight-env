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

env_stage "Verifying prerequisites"
if [ ! -d "${flight_ENV_ROOT}"/share/modules/3.2.10 ]; then
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
  tcl_params="--with-tcl=${flight_ENV_ROOT}/share/tcl/8.6.9/lib --with-tcl-ver=8.6 --without-tclx --with-tclx-ver=8.6"
  if [ ! -f modules-3.2.10.tar.gz ]; then
    env_stage "Fetching prerequisite (modules)"
    wget https://sourceforge.net/projects/modules/files/Modules/modules-3.2.10/modules-3.2.10.tar.gz
  fi
  env_stage "Extracting prerequisite (modules)"
  tar xvf modules-3.2.10.tar.gz
  env_stage "Building prerequisite (modules)"
  cd modules-3.2.10
  CPPFLAGS="-DUSE_INTERP_ERRORLINE" ./configure \
          --disable-versioning \
          --prefix=${flight_ENV_ROOT}/share/modules/3.2.10 $tcl_params
  make
  env_stage "Installing prerequisite (modules)"
  make install
  cd ..
  rm -f ${flight_ENV_ROOT}/share/modules/3.2.10/Modules/init/.modulespath
  touch ${flight_ENV_ROOT}/share/modules/3.2.10/Modules/init/.modulespath
fi

if [ ! -d "${flight_ENV_ROOT}/share/gridware/1.5.1" ]; then
  if [ ! -f gridware-legacy-1.5.1.tar.gz ]; then
    env_stage "Fetching prerequisite (gridware)"
    wget https://github.com/alces-flight/gridware-legacy/archive/master.tar.gz -O gridware-legacy-1.5.1.tar.gz
  fi
  env_stage "Extracting prerequisite (gridware)"
  tar xvf gridware-legacy-1.5.1.tar.gz
  env_stage "Installing prerequisite (gridware)"
  mkdir -p "${flight_ENV_ROOT}/share/gridware/1.5.1"
  cp -R gridware-legacy-master/* "${flight_ENV_ROOT}/share/gridware/1.5.1"
  cd ${flight_ENV_ROOT}/share/gridware/1.5.1
  export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
  /opt/flight/bin/flexec bundle install --path=vendor --without=development --without=test --local
fi

if [ ! -d "${flight_ENV_ROOT}/share/gridware/repos/main" ]; then
  env_stage "Configuring repo: main"
  mkdir -p "${flight_ENV_ROOT}/share/gridware/repos/main"
  cat <<EOF > "${flight_ENV_ROOT}/share/gridware/repos/main/repo.yml"
################################################################################
##
## Alces Clusterware - Gridware repository configuration
## Copyright (c) 2012-2016 Alces Software Ltd
##
################################################################################
---
:source: https://github.com/alces-software/gridware-packages-main.git
:schema: 2
EOF
fi

if [ ! -d "${flight_ENV_ROOT}/share/gridware/repos/volatile" ]; then
  env_stage "Configuring repo: volatile"
  mkdir -p "${flight_ENV_ROOT}/share/gridware/repos/volatile"
  cat <<EOF > "${flight_ENV_ROOT}/share/gridware/repos/volatile/repo.yml"
################################################################################
##
## Alces Clusterware - Gridware repository configuration
## Copyright (c) 2012-2016 Alces Software Ltd
##
################################################################################
---
:source: https://github.com/alces-software/packager-base.git
:schema: 1
EOF
fi

env_stage "Creating environment (gridware@${name})"
mkdir -p ${flight_ENV_ROOT}/gridware+${name}/depots
mkdir -p ${flight_ENV_ROOT}/gridware+${name}/etc
mkdir -p ${flight_ENV_CACHE}/gridware/logs/gridware+${name}
mkdir -p ${flight_ENV_CACHE}/gridware/archives
mkdir -p ${flight_ENV_CACHE}/gridware/src
cat <<EOF > ${flight_ENV_ROOT}/gridware+${name}/gridware.bash.rc
module use ${flight_ENV_ROOT}/gridware+${name}/local/el7/etc/modules
export ALCES_CONFIG_PATH="${flight_ENV_ROOT}/gridware+${name}/etc"
export cw_DIST=el7
EOF
cat <<EOF > ${flight_ENV_ROOT}/gridware+${name}/gridware.tcsh.rc
module use ${flight_ENV_ROOT}/gridware+${name}/local/el7/etc/modules
setenv ALCES_CONFIG_PATH "${flight_ENV_ROOT}/gridware+${name}/etc"
setenv cw_DIST el7
EOF
cat <<EOF > ${flight_ENV_ROOT}/gridware+${name}/etc/gridware.yml
################################################################################
##
## Alces Clusterware - Gridware packager configuration
## Copyright (c) 2012-2016 Alces Software Ltd
##
################################################################################
---
:log_root: ${flight_ENV_CACHE}/gridware/logs/gridware+${name}
:repo_paths:
 - ${flight_ENV_ROOT}/share/gridware/repos/main
 - ${flight_ENV_ROOT}/share/gridware/repos/volatile
# - ${flight_ENV_ROOT}/share/gridware/repos/local
:depotroot: ${flight_ENV_ROOT}/gridware+${name}
:default_depot: local
:archives_dir: ${flight_ENV_CACHE}/gridware/archives
:buildroot: ${flight_ENV_CACHE}/gridware/src
:fallback_package_url: https://s3-eu-west-1.amazonaws.com/alces-gridware-eu-west-1/upstream
:default_binary_url: https://s3-eu-west-1.amazonaws.com/alces-gridware-eu-west-1/dist
:fetch_timeout: 10
:prefer_binary: false
:use_default_params: false
:update_period: 3
:last_update_filename: .last_update
#:user_email: someone@example.com
EOF
cat <<EOF > ${flight_ENV_ROOT}/gridware+${name}/etc/params.yml
'apps/example':
  :optimize: true
'apps/example/1.0.1':
  :optimize: false
EOF

depot="$(echo "${flight_ENV_ROOT}/gridware+${name}/depots/$(uuid -v4 | cut -f1 -d'-')")"
dname="local"
cd ${flight_ENV_ROOT}/gridware+${name}
ln -snf "${depot}" "${dname}"
mkdir -p "${depot}/el7/pkg" "${depot}/el7/etc"
cp -R ${flight_ENV_ROOT}/share/gridware/1.5.1/etc/depotskel/* "${depot}/el7/etc"

export HOME=${HOME:-$(eval echo "~$(whoami)")}
export ALCES_CONFIG_PATH="${flight_ENV_ROOT}/gridware+${name}/etc"
export cw_DIST=el7
if [ -x "${flight_ROOT}"/bin/ruby ]; then
  RUBY="${flight_ROOT}"/bin/ruby
else
  RUBY="$(which ruby &>/dev/null)"
fi
cat <<RUBY | "${RUBY}"
ENV['BUNDLE_GEMFILE'] ||= "${flight_ENV_ROOT}/share/gridware/1.5.1/Gemfile"
\$: << "${flight_ENV_ROOT}/share/gridware/1.5.1/lib"

require 'rubygems'
require 'bundler'
Bundler.setup(:default)

require 'alces/packager/package'

system_gcc_opts = {
  type: 'compilers',
  name: 'gcc',
  version: \`/usr/bin/gcc -dumpversion\`.chomp,
  default: true,
  path: 'compilers/gcc/system'
}

DataMapper.repository(:'${dname}') do
  Alces::Packager::Package.create!(system_gcc_opts)
end
RUBY
