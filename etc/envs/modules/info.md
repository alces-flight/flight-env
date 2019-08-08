# modules(7) -- Provides dynamic modification of a user's environment

## SYNOPSIS

Typically users initialize their environment when they log in by
setting environment information for every application they will
reference during the session. The Environment Modules package is a
tool that simplify shell initialization and lets users easily modify
their environment during the session with modulefiles.

Each modulefile contains the information needed to configure the shell
for an application. Once the Modules package is initialized, the
environment can be modified on a per-module basis using the module
command which interprets modulefiles. Typically modulefiles instruct
the module command to alter or set shell environment variables such as
PATH, MANPATH, etc. modulefiles may be shared by many users on a
system and users may have their own collection to supplement or
replace the shared modulefiles.

Modules can be loaded and unloaded dynamically and atomically, in an
clean fashion. All popular shells are supported, including bash, ksh,
zsh, sh, csh, tcsh, fish, as well as some scripting languages such as
perl, ruby, tcl, python, cmake and R.

Modules are useful in managing different versions of
applications. Modules can also be bundled into metamodules that will
load an entire suite of different applications.

## ENVIRONMENT CREATION

This environment provides Environment Modules v4.3.0. It is possible
to create either user-level modules-based environments or, if you have
write access to the global environment tree, to create system-wide
modules-based environments.

### Personal Environment

A personal Environment Modules environment can be created using:

```
%PROGRAM_NAME% create modules
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create modules@myenv
```

This will configure an empty Environment Modules environment
configured with the `module` command for managing environment modules.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate modules
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create modules@myenv
```

Under an Environment Modules environment, software installations are
manually managed, and _modulefiles_ are created to handle any required
environmental set up for access to the software. Read [the
`modulefile` documentation](https://modules.readthedocs.io/en/stable/modulefile.html)
for more details on how to write modulefiles.

Once written, _modulefiles_ should be placed in the `modulefiles/`
subdirectory of the environment.

To see what modules are installed within your environment use the
`module avail` command:

```
<modules> [user@login1 ~]$ module avail
------ /home/user/.local/share/flight/env/modules+default/modulefiles -------
null

---- /home/user/.local/share/flight/env/share/modules/4.3.0/modulefiles -----
dot  module-git  module-info  modules  null  use.own
```

Modules are loaded using the `module load` command.

Refer to the [Environment Modules command line reference
documentation](https://modules.readthedocs.io/en/stable/module.html)
for more details.

The behaviour at initialization of the environment can be modified by
adding `module` commands to the `modules.bash.rc` script held in the
environment directory. By default, this file adds the `modulefiles/`
subdirectory, but further module hierarchies and initially loaded
modules can be added as required. e.g.:

```
<modules> [user@login1 flight-env]$ cat ~/.local/share/flight/env/modules+default/modules.bash.rc
module use /home/user/.local/share/flight/env/modules+default/modulefiles
module use /home/user/modulefiles
module load apps/gcc/samtools
```

### Global Environment

If you have write access to the global environment tree, a shared
Environment Modules environment can be created using:

```
%PROGRAM_NAME% create --global modules
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global modules@global
```

This will configure an empty Environment Modules environment
configured with the `module` command for managing environment modules.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate modules
# ...or to activate the environment named 'global':
%PROGRAM_NAME% create modules@global
```

Note that only users who have write access to the global environment
tree are able to add _modulefiles_ to the shared environment, though
any user may use modules located in the shared hierarchy by using the
`module load` command.

Under an Environment Modules environment, software installations are
manually managed, and _modulefiles_ are created to handle any required
environmental set up for access to the software. Read [the
`modulefile` documentation](https://modules.readthedocs.io/en/stable/modulefile.html)
for more details on how to write modulefiles.

Once written, _modulefiles_ should be placed in the `modulefiles/`
subdirectory of the environment.

Modules are loaded using the `module load` command.

Refer to the [Environment Modules command line reference
documentation](https://modules.readthedocs.io/en/stable/module.html)
for more details.

The behaviour at initialization of the environment can be modified by
adding `module` commands to the `modules.bash.rc` script held in the
environment directory. By default, this file adds the `modulefiles/`
subdirectory, but further module hierarchies and initially loaded
modules can be added as required. e.g.:

```
<modules@global> [root@admin01 ~]$ cat /opt/flight/var/lib/env/modules+global/modules.bash.rc
module use /opt/flight/var/lib/env/modules+global/modulefiles
module use /opt/apps/etc/modules
module use /opt/site/sw/modules
```

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
