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
container. This is one of Singularities defining characteristics,
allowing a user (that may already have shell access to a particular
host) to simply run a command inside of a container image as
themselves.

For more details, please refer to the comprehensive Singularity
documentation at <https://www.sylabs.io/guides/3.2/user-guide/>.

## ENVIRONMENT CREATION

This environment provides Singularity v3.2.1. It is possible to create
either user-level Singularity environments or, if you have superuser
access, to create system-wide Singularity environments.

### Personal Environment

**NB. Personal Singularity environments have several restrictions and,
as such, are experimental.** You may need to make requests to your
system administrators to perform operations that require superuser
access if your distribution does not contain support for [user
namespaces](http://man7.org/linux/man-pages/man7/user_namespaces.7.html). Most
modern Linux distributions do contain support, but it is not yet
universally enabled by default (notably CentOS 7.x does not yet enable
user namespaces by default).

### System Environment

**Notes about installing system-wide here.**

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
