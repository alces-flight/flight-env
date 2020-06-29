# example(7) -- Example environment for Flight Environment

## SYNOPSIS

This is an example environment that shows the layout and required
files to provide a software environment under Flight Environment.

## ENVIRONMENT CREATION

This environment creates an example directory containing an example
file. It is an example.

### Personal Environment

A personal example environment can be created using:

```
%PROGRAM_NAME% create example
# ...or to create an environment named 'myenv':
%PROGRAM_NAME% create example@myenv
```

This will configure the example environment.

Once created, activate your environment using:

```
%PROGRAM_NAME% activate example
# ...or to activate the environment named 'myenv':
%PROGRAM_NAME% create example@myenv
```

No commands are supplied and the example environment does not provide
any functionality.

### Global Environment

If you have write access to the global environment tree, a shared
example environment can be created using:

```
%PROGRAM_NAME% create --global example
# ...or to create a environment named 'global':
%PROGRAM_NAME% create --global example@global
```

This will configure the example environment.

Once created, the environment can be activated by any user using:

```
%PROGRAM_NAME% activate example
# ...or to activate the environment named 'global':
%PROGRAM_NAME% activate example@global
```

Note that only users who have write access to the global environment
tree are able to install packages to a shared environment, though any
user may use installed packages.

No commands are supplied and the example environment does not provide
any functionality.

## LICENSE

This work is licensed under a Creative Commons Attribution-ShareAlike
4.0 International License.

See <http://creativecommons.org/licenses/by-sa/4.0/> for more
information.

## COPYRIGHT

Copyright (C) 2020-Present Alces Flight Ltd.
