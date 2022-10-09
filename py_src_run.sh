#!/bin/bash
# .: py_src_run.sh (run.sh) :.
# Main backend invokation script
# Author: Timothy C. Quinn
# Home: https://github.com/JavaScriptDude/py_src_run

# .: Installation :.
#%  mkdir ~/.py_src_run
#%  _C=py_src_run _D=~/.${_C} && cp ./${_C}.sh $_D/run.sh && chmod a+x $_D/run.sh

PYINITERR=""
if [ "$#" -lt  "2" ]; then
    PYINITERR="Invalid args. Expecting <scr_path> <module> [<program_arg1>, ...]"
fi

# Parse Module Src Path
if [[ $PYINITERR == "" ]]; then
    MSPATH="$1"
    if [ ! -d "$MSPATH" ]; then
        PYINITERR="Module path provided to py_run_as_root does not exist: ${MSPATH}"
    fi
fi

# Parse Module
if [[ $PYINITERR == "" ]]; then
    MOD="$2"
    if [ ! -d "$MSPATH/$MOD" ]; then
        PYINITERR="Module provided to py_run_as_root does not exist: $MSPATH/$MOD"
    fi
fi

# Get HOME and pyinit.sh location
if [[ $PYINITERR == "" ]]; then
    SCRP="$0"
    SCR_FILE=`basename $SCRP`
    PYRUNDIR=`dirname $SCRP`
    
    readarray -d / -t a<<< "$PYRUNDIR"

    PERR=0
    PERRMSG=""
    if [ "${#a[@]}" != "4" ]; then
        PERR=1
    elif [[ "${a[0]}" != "" ]]; then
        PERR=1
    elif [[ "${a[1]}" != "home" ]]; then
        PERR=1
    else
        export HOME=/home/${a[2]}
        LASTP=${a[3]}
        if [[ "${LASTP:0:11}" != ".py_src_run" ]]; then
            PERR=1
        else
            # Verify that pyinit.sh exists
            if [ ! -f "$PYRUNDIR/pyinit.sh" ]; then 
                PERR=1
                PERRMSG="pyinit init script is missing: '$PYRUNDIR/pyinit.sh'"
            fi
        fi
    fi



    if [ $PERR == 1 ]; then
        if [[ "$PERRMSG" != "" ]]; then
            PYINITERR=$PERRMSG
        else
            PYINITERR="Invalid path for py_src_run.sh. Expecting /home/<user>/.py_src_run/run.sh but got ${SCR_DIR}"
        fi
    fi

fi

if [[ $PYINITERR == "" ]]; then
    # source pyinit script
    source $PYRUNDIR/pyinit.sh
fi    

if [[ $PYINITERR == "" ]]; then
    # Add module path to PYTHONPATH
    export PYTHONPATH=${MSPATH}:${PYTHONPATH}

    # strip first two cli args
    shift 2

    if [ 0 -eq 1 ]; then # debug
        echo FOO=\'$FOO\'
        echo MSPATH=\'$MSPATH\'
        echo MOD=\'$MOD\'
        echo MOD Args=\'$@\'
        echo HOME=\'$HOME\'
        echo PATH=\'$PATH\'
        echo PYTHONPATH=\'$PYTHONPATH\'
        echo PY_EXE=`python -c "import sys; print(sys.executable);"`
    fi

    # Execute
    python -m $MOD "$@"

else
    echo "py_run_from_src.sh failed - $PYINITERR"
    echo " . CLI Args: '$@'"

fi