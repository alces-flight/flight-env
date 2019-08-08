# singularity(7) -- container solution for scientific and application driven workloads

## SYNOPSIS

Singularity is an open-source container platform platform that has
been created to support high-performance computing (HPC) and research
workloads. First released in 2016, the container solution was created
by necessity for scientific and application driven workloads and aims
to support four primary functions:

  * Mobility of compute.
  * Reproducibility.
  * User freedom.
  * Support existing traditional HPC environments.

A user inside a Singularity container is the same user as outside the
container. This is one of Singularity's defining characteristics,
allowing a user (that may already have shell access to a particular
host) to simply run a command inside of a container image as
themselves.

For more details, please refer to the comprehensive Singularity
documentation at <https://www.sylabs.io/guides/3.2/user-guide/>.

## ENVIRONMENT CREATION

This environment provides Singularity v3.2.1. It is possible to create
either user-level Singularity environments or, if you have write
access to the global environment tree, to create system-wide
Singularity environments.

### Personal Environment

**NB. Personal Singularity environments have several restrictions and,
as such, are experimental.** You may need to make requests to your
system administrators to perform operations that require superuser
access if your distribution does not contain support for [user
namespaces](http://man7.org/linux/man-pages/man7/user_namespaces.7.html). Most
modern Linux distributions do contain support, but it is not yet
universally enabled by default (notably CentOS 7.x does not yet enable
user namespaces by default).

If user namespaces are not enabled, you may receive an error such as:

```
ERROR  : Failed to create user namespace
```

To enable user namespace access (required to allow user-level access
to execute singularity container instances), request that your system
administrator sets `/proc/sys/user/max_user_namespaces` to a
(non-zero) value high enough to allow for the quantity of simultaneous
Singularity containers that will be executed on the host. We recommend
a value of `100`.

A personal Singularity environment can be created using:

```
%PROGRAM_NAME% create singularity
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create singularity@myenv
```

This will configure a Singularity installation and an, initially
empty, image cache environment.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate singularity
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create singularity@myenv
```

Use the `singularity` command to perform image management for your
environment:

```
singularity --help
```

To see what images are cached within your environment use the
`singularity cache list` command; to execute a prebuilt image use
`singularity run application.img`; to run a shell within an image use
`singularity shell ...` and to build images use `singularity build
...`.

Refer to the [Singularity user
guide](https://sylabs.io/guides/3.2/user-guide/) for more details.

### Global Environment

If you have write access to the global environment tree, a shared
Singularity environment can be created using:

```
%PROGRAM_NAME% create --global singularity
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global singularity@global
```

This will configure a Singularity installation and an, initially
empty, image cache environment.

Once created, the environment can be activated by any user using:

```
%PROGRAM_NAME% activate singularity
# ...or to activate the environment named 'global':
%PROGRAM_NAME% activate singularity@global
```

Note that only users who have write access to the global environment
tree are able to download upstream images to a shared environment.

If the environment was created by the superuser (root), then any user
may execute a cached or direct image, or run a shell within a cached or
direct image by using the `singularity` command provided by the shared
environment.

Use the `singularity` command to perform image management for your
environment:

```
singularity --help
```

To see what images are cached within your environment use the
`singularity cache list` command; to execute a prebuilt image use
`singularity run application.img`; to run a shell within an image use
`singularity shell ...` and to build images use `singularity build
...`.

Refer to the [Singularity user
guide](https://sylabs.io/guides/3.2/user-guide/) for more details.

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
