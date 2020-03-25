# gridware(7) -- Tool for installing and managing scientific applications and libraries.

## SYNOPSIS

Alces Gridware provides access to a curated collection of scientific
applications and libraries ready to install on your HPC environment,
ensuring you've got absolutely everything you need and allowing your
analysis to start as quickly as possible.

Covering many fields of scientific research, from fluid dynamics to
molecular dynamics, bioinformatics to statistics, machine learning to
electron microscopy, Gridware provides a comprehensive research
toolkit.

Gridware allows you the freedom to install your own selection of key
applications -- with all dependencies satisfied and appearing
automatically alongside your selections.

From the installation of multiple versions of the same application to
building your own architecture- and environment-optimized software,
Gridware has got you covered. And for those who want to get started
quickly you can install many applications from one of our prebuilt
binary repositories.

## ENVIRONMENT CREATION

This environment provides Gridware v1.5.3. It is possible to create
either user-level Gridware environments or, if you have write access
to the global environment tree, to create system-wide Gridware
environments.

### Personal Environment

A personal Gridware environment can be created using:

```
%PROGRAM_NAME% create gridware
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create gridware@myenv
```

This will configure a base Gridware environment configured with the
`module` command (or `mod` for short) for managing environment
modules.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate gridware
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create gridware@myenv
```

Software installation can be managed using the `gridware` command (or
`gr` for short).

To see what modules are installed within your environment use the
`module avail` command:

```
<gridware> [user@login1 ~]$ module avail
---  /home/user/.local/share/flight/env/gridware+default/local/el7/etc/modules  ---
  apps/memtester/4.3.0/gcc-4.8.5
  compilers/gcc/system
  libs/gcc/system
  null
```

Modules are loaded using the `module load` command.

The behaviour at initialization of the environment can be modified by
adding `module` commands to the `gridware.bash.rc` script held in the
environment directory. By default, this file adds the `etc/modules/`
subdirectory to the modules search path and sets the Gridware
configuration file to `etc/gridware.yml`, but further module
hierarchies, initially loaded modules and further configuration can be
added as required. e.g.:

```
<gridware> [user@login1 ~]$ cat ~/.local/share/flight/env/gridware+default/gridware.bash.rc
module use /home/user/.local/share/flight/env/gridware+default/local/el7/etc/modules
export ALCES_CONFIG_PATH="/home/vagrant/.local/share/flight/env/gridware+default/etc"
export cw_DIST=el7
```

### Global Environment

If you have write access to the global environment tree, a shared
Gridware environment can be created using:

```
%PROGRAM_NAME% create --global gridware
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global gridware@global
```

This will configure a base Gridware environment configured with the
`module` command (or `mod` for short) for managing environment
modules.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate gridware
# ...or to activate the environment named 'global':
%PROGRAM_NAME% create gridware@global
```

Note that only users who have write access to the global environment
tree are able to manage packages within the shared environment using
the `gridware` tool, though any user may use modules located in the
shared hierarchy by using the `module load` command.

Software installation can be managed using the `gridware` command (or
`gr` for short).

Modules are loaded using the `module load` command.

The behaviour at initialization of the environment can be modified by
adding `module` commands to the `gridware.bash.rc` script held in the
environment directory. By default, this file adds the `etc/modules/`
subdirectory to the modules search path and sets the Gridware
configuration file to `etc/gridware.yml`, but further module
hierarchies, initially loaded modules and further configuration can be
added as required. e.g.:

```
<gridware@global> [root@login1 ~]$ cat /opt/flight/var/lib/env/gridware+global/gridware.bash.rc
module use /opt/flight/var/lib/env/gridware+global/local/el7/etc/modules
export ALCES_CONFIG_PATH="/opt/flight/var/lib/env/gridware+global/etc"
export cw_DIST=el7
```

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
