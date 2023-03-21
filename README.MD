## Python Src Run
Tool for generating and invoking of python sources that does not require installation in python libraries

Supports executing code as user and as root (eg as cron tasks). Tooled to leverage a separate python environment from the systems python, therefore allow userland applications to have flexibility of library installation without conflicting with the base systems python environment; as is best practice.


## Applications
When a project is in alpha state, its often not ready to be packaged in PyPi for the main stream. Secondly, sometimes the process for packaging a python application to make it easy to deploy in production environments can be challenging. This tool offers a bridge to allow tools be be developed and tested without having to deal with packaging and installation by allowing them to be run directly from source.


## Project Install File
Each project that uses this toolset, will have a <mod>_install.sh in its root file similar to the following:
```
#!/bin/bash
# % cd <this directory>
# % . ./pynx_install.sh
. ~/.py_src_run/make_mod_exe.sh "pynx" "/usr/bin" "lib,foo/bar"
```

This above example will deploy an executable called `pynx` to `/usr/bin`, It will also include in PYTHONPATH <project_root>/lib and <project_root>/foo/bar

By deploying to `/usr/bin`, the program can be invoked using sudo, which in the case of `pynx`, su is required as its for managing `nginx` and `wsgi`.


## Files
| Name | Deployed Name | Description |
---|---|---
| py_src_run.sh | run.sh | Backend invocation script. No modification required |
| make_mod_exe.sh | (same) | script for generating executable. No modification required |
| pyinit.sh | (same) | script to set up python environment. Configuration is required |

Files are deployed to ~/.py_src_run/

Python environment used is suggested to be installed via `pyenv` but virtual env's could be used in theory. Virutal env's  have  not been tested yet as `pyenv` is the developers prefered mechanism for desktops and production server python deployments. 


## src directory
This design assumes that the python project has a src directory in the root of the file structure as is recommended by most modern documentation on python project setup.


## Installation
Download the sources
For each of `py_src_run.sh`, `make_mod_exe.sh` and `pyinit.sh` install by either following instructions in header of each file or run the following in a `bash shell`:
```
_P=py_src_run
mkdir ~/.${_P}
cp ./$_P.sh ~/.$_P/run.sh && chmod a+x ~/.$_P/run.sh
_C=make_mod_exe && cp ./$_C.sh ~/.$_P/$_C.sh && chmod a+x ~/.$_P/$_C.sh
_C=pyinit && cp ./$_C.sh ~/.$_P/$_C.sh
```

## Configuration
Besides generating a install script for any project you want to install, you must modify `~/.py_run_src/pyinit.sh`

This file will initialze the python environment


