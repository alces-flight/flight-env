# Flight Environment

Manage and access HPC application environments.

## Overview

Flight Environment provides access to common package environments for
managing HPC applications and libraries. Multiple environments can be
managed with the ability to switch between them as required.

## Installation

### Installing with the OpenFlight package repos

Flight Environment is available as part of the *Flight User Suite*.  This is the
easiest method for installing Flight Environment and all its dependencies.  It is
documented in [the OpenFlight
Documentation](https://docs.openflighthpc.org/hpc_environment_usage/ecosystems/flight_environment/).

### Manual Installation

While manual installation is not normally required or recommended, if you're
not using Enterprise Linux or want to set things up yourself directly from the
repository, you can do so by following the steps below.

#### Prerequisites

Flight Environment is developed and tested with Ruby version `2.7.1` and
`bundler` `2.1.4`.  Other versions may work but currently are not officially
supported.

#### Install Flight Environment

The following will install from source using `git`.  The `master` branch is
the current development version and may not be appropriate for a production
installation. Instead a tagged version should be checked out.

```bash
git clone https://github.com/alces-flight/flight-env.git
cd flight-env
git checkout <tag>
bundle install
```

Use the script located at `bin/flenv` to execute the tool.

## Configuration

Making changes to the default configuration is optional and can be achieved by
creating a `config.yml` file in the `etc/` subdirectory of the tool.  A
`config.yml.ex` file is distributed which outlines all the configuration
values available:

 * `global_depot_path` - This setting defines where global ecosystems should be installed, it is recommended that this be somewhere accessible by all users on the system (defaults to `/opt/flight/var/lib/env`)
 * `global_build_cache_path` - This setting defines where global ecosystems are built (the location of build logs, dependencies and other information on the build) (defaults to `/opt/flight/var/cache/env/build`)

## Operation

A brief usage guide is given below.  More details can be found by running
`bin/flenv --help`.  If Flight Environment was installed via the OpenFlight
package repos, you can read more detailed usage instructions by running
`flight howto show flight env`.


Display the range of available software ecosystems using the `avail` command.

Create an ecosystem with the `create` command, providing the argument of an
ecosystem from the list above. 

Activate an ecosystem using the `activate` command, this will expose the
ecosystem's commands to the shell. Exit the ecosystem using the `deactivate`
command.

Show the configured ecosystems using the `list` command.

Remove an ecosystem using the `purge` command.

See the `help` command for further details and information about other
commands. Further information and examples of the `env` command are available
in [the OpenFlight
documentation](https://docs.openflighthpc.org/hpc_environment_usage/ecosystems/flight_environment/).

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# Copyright and License

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2019-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Flight Environment is distributed in the hope that it will be
useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE. See the [Eclipse Public License 2.0](https://opensource.org/licenses/EPL-2.0) for more
details.
