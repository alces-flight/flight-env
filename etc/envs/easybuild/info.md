# easybuild(7) -- software build and installation framework.

## SYNOPSIS

EasyBuild is a software build and installation framework that allows
you to manage (scientific) software on High Performance Computing
(HPC) systems in an efficient way. It is motivated by the need for a
tool that combines the following features:

 * a flexible framework for building/installing (scientific) software
 * fully automates software builds
 * divert from the standard configure / make / make install with custom procedures
 * allows for easily reproducing previous builds
 * keep the software build recipes/specifications simple and human-readable
 * supports co-existence of versions/builds via dedicated installation prefix and module files
 * enables sharing with the HPC community (win-win situation)
 * automagic dependency resolution
 * retain logs for traceability of the build processes

## ENVIRONMENT CREATION

This environment provides the latest available version of
EasyBuild. It is possible to create either user-level EasyBuild
environments or, if you have write access to the global environment
tree, to create system-wide EasyBuild environments.

### Personal Environment

A personal EasyBuild environment can be created using:

```
%PROGRAM_NAME% create easybuild
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create easybuild@myenv
```

This will configure a minimal EasyBuild environment configured with
the _Lmod_ tool for managing environment modules and populated with an
EasyBuild module for access to the `eb` build and management tool.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate easybuild
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create easybuild@myenv
```

To access the `eb` command, load the `EasyBuild` module:

```
module load EasyBuild
eb --help
```

Use the `eb` command to perform package management for your
environment.

To see what modules are installed within your environment use the
`module avail` command:

```
<easybuild> [user@login01 ~]$ module avail

------- /home/user/.local/share/flight/env/easybuild+default/modules/all -------
   EasyBuild/3.9.3

- /home/user/.local/share/flight/env/share/lmod/8.1/lmod/lmod/modulefiles/Core -
   lmod    settarg

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching
any of the "keys".
```

Refer to the [EasyBuild command line reference
documentation](https://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html)
for more details.

### Global Environment

If you have write access to the global environment tree, a shared
EasyBuild environment can be created using:

```
%PROGRAM_NAME% create --global easybuild
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global easybuild@global
```

This will configure a minimal EasyBuild environment configured with
the _Lmod_ tool for managing environment modules and populated with an
EasyBuild module for access to the `eb` build and management tool.

Once created, the environment can be activated by any user using:

```
%PROGRAM_NAME% activate easybuild
# ...or to activate the environment named 'global':
%PROGRAM_NAME% activate easybuild@global
```

Note that only users who have write access to the global environment
tree are able to install packages to a shared environment, though any
user may use installed packages by using the `module load` command.

To install and manage packages, use the `eb` command, accessible by
loading the `EasyBuild` module:

```
module load EasyBuild
eb --help
```

Refer to the [EasyBuild command line reference
documentation](https://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html)
for more details.

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
