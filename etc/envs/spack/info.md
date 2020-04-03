# spack(7) -- A flexible package manager that supports multiple versions, configurations, platforms, and compilers.

## SYNOPSIS

Spack is a package management tool designed to support multiple
versions and configurations of software on a wide variety of platforms
and environments. It was designed for large supercomputing centers,
where many users and application teams share common installations of
software on clusters with exotic architectures, using libraries that
do not have a standard ABI. Spack is non-destructive: installing a new
version does not break existing installations, so many configurations
can coexist on the same system.

Most importantly, Spack is simple. It offers a simple spec syntax so
that users can specify versions and configuration options
concisely. Spack is also simple for package authors: package files are
written in pure Python, and specs allow package authors to maintain a
single file for many different builds of the same package.

Spack isn't tied to a particular language; you can build a software
stack in Python or R, link to libraries written in C, C++, or Fortran,
and easily swap compilers. Use Spack to install in your home
directory, to manage shared installations and modules on a cluster, or
to build combinatorial versions of software for testing.

## ENVIRONMENT CREATION

This environment provides Spack v0.14.1. It is possible to create
either user-level Spack environments or, if you have write access to
the global environment tree, to create system-wide Spack environments.

### Personal Environment

A personal Spack environment can be created using:

```
%PROGRAM_NAME% create spack
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create spack@myenv
```

This will configure a minimal Spack environment configured with the
_Environment Modules_ tool for accessing environment modules, and
access to the `spack` tool for managing package installations.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate spack
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create spack@myenv
```

Use the `spack` command to perform package management for your
environment:

```
spack --help
```

To see what modules are installed within your environment use the
`module avail` command:

```
<spack> [user@login1 ~]$ module avail

- /home/user/.local/share/flight/env/spack+default/share/spack/modules/linux-centos7-x86_64 --
environment-modules-3.2.10-gcc-4.8.5-k5d3cqq zlib-1.2.11-gcc-4.8.5-64vg6e4
tcl-8.6.8-gcc-4.8.5-5cbp3st
```

Refer to the [Spack basic usage
documentation](https://spack.readthedocs.io/en/latest/basic_usage.html)
for more details.

### Global Environment

If you have write access to the global environment tree, a shared
Spack environment can be created using:

```
%PROGRAM_NAME% create --global spack
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global spack@global
```

This will configure a minimal Spack environment configured with the
_Environment Modules_ tool for accessing environment modules, and
access to the `spack` tool for managing package installations.

Once created, the environment can be activated by any user using:

```
%PROGRAM_NAME% activate spack
# ...or to activate the environment named 'global':
%PROGRAM_NAME% activate spack@global
```

Note that only users who have write access to the global environment
tree are able to install packages to a shared environment, though any
user may use installed packages by using the `module load` command.

Use the `spack` command to perform package management for your
environment:

```
spack --help
```

To see what modules are installed within your environment use the
`module avail` command.

Refer to the [Spack basic usage
documentation](https://spack.readthedocs.io/en/latest/basic_usage.html)
for more details.

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
