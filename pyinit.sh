#!/bin/bash
# .: pyinit.sh :.
# Python environment initialization for py_src_run invocations

# Author: Timothy C. Quinn
# Home: https://github.com/JavaScriptDude/py_src_run

# .: Installation :.
# note: install py_src_run.sh first
#%  _C=pyinit _D=~/.py_src_run && cp ./${_C}.sh $_D/${_C}.sh


# Modify as required

# Example for pyenv
export _PYVER=3.7.9
export PATH=${HOME}/.pyenv/versions/${_PYVER}/bin/:${PATH}
