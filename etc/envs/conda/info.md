# conda(7) -- Package, dependency and environment management for any language.

## SYNOPSIS

Conda is an open source package management system and environment
management system that runs on Windows, macOS, and Linux. Conda
quickly installs, runs and updates packages and their
dependencies. Conda easily creates, saves, loads, and switches between
environments on your local computer. It was created for Python
programs but it can package and distribute software for any language.

Conda as a package manager helps you find and install packages. If you
need a package that requires a different version of Python, you do not
need to switch to a different environment manager because conda is
also an environment manager. With just a few commands, you can set up
a totally separate environment to run that different version of
Python, while continuing to run your usual version of Python in your
normal environment.

Miniconda is a free minimal installer for conda. Miniconda is a small,
bootstrap version of Anaconda that includes only conda, Python, the
packages they depend on and a small number of other useful packages,
including pip, zlib and a few others. Use the conda install command to
install 720+ additional conda packages from the Anaconda repository.

## ENVIRONMENT CREATION

This environment provides the latest available version of
Miniconda3. It is possible to create either user-level Conda
environments or, if you have write access to the global environment
tree, to create system-wide Conda environments.

### Personal Environment

A personal Conda environment can be created using:

```
%PROGRAM_NAME% create conda
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create conda@myenv
```

This will configure a minimal Conda environment which can be populated
using the `conda install` command.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate conda
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create conda@myenv
```

Use the `conda` command to perform package management for your
environment. Refer to the [Conda command reference
documentation](https://docs.conda.io/projects/conda/en/latest/commands.html)
for more details.

### Global Environment

If you have write access to the global environment tree, a shared
Conda environment can be created using:

```
%PROGRAM_NAME% create --global conda
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global conda@global
```

This will configure a minimal Conda environment which can be populated
using the `conda install` command.

Once created, the environment can be activated by any user using:

```
%PROGRAM_NAME% activate conda
# ...or to activate the environment named 'global':
%PROGRAM_NAME% activate conda@global
```

Note that only users who have write access to the global environment
tree are able to install packages to a shared environment, though any
user may use installed packages.

A user may create their own Conda environments by using the `conda
create` command which makes use of the basic utilities provided by
the Conda installation but allows them to manage their own package
hierarch(y/ies):

```
conda create -n myenv
# ...to activate after creation:
conda activate myenv
```

Refer to the [Conda command reference
documentation](https://docs.conda.io/projects/conda/en/latest/commands.html)
for more details.

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2019-Present Alces Flight Ltd.
