# Flight Environment

Manage and access HPC application environments.

## Overview

Flight Environment provides access to common package environments for
managing HPC applications and libraries. Multiple environments can be
managed with the ability to switch between them as required.

## Installation

### From the OpenFlight `yum` repository

The installation of Flight Environment and the Flight User Suite is documented in [the OpenFlight Documentation](https://use.openflighthpc.org/en/latest/installing-user-suite/install.html#installing-flight-user-suite).

### Manual Installation

While manual installation is not normally required or recommended, if you're not using Enterprise Linux or want to set things up yourself directly from the repository, you can do so by following the steps below.

#### Prerequisites

You will need a functional Ruby 2.5+ environment (one installed via RVM or similar works well) along with the Bundler tool.

#### Steps

1. Create the installation directory and clone repository

    ```bash
    mkdir -p /opt/flight/opt/
    git clone https://github.com/openflighthpc/flight-env /opt/flight/opt/env
    ```

2. Install gems
   
    ```bash
    cd /opt/flight/opt/env
    bundle install
    ```

## Configuration

TBC.

## Operation

TBC.

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
