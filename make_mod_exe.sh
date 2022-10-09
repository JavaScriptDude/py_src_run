#!/bin/bash
# .: make_mod_exe.sh :.
# Executable creator script

# Author: Timothy C. Quinn
# Home: https://github.com/JavaScriptDude/py_src_run

# .: Installation :.
# note: install py_src_run.sh first
# %  _C=make_mod_exe _D=~/.py_src_run && cp ./${_C}.sh $_D/${_C}.sh && chmod a+x $_D/${_C}.sh

PROJ_ROOT=`pwd`
ERR=""
if [[ "$#" ==  "" ]]; then
    ERR="Invalid args. Expecting <module> <target_bin_dir>"
else
    user_is_root () { [ ${EUID:-$(id -u)} -eq 0 ]; }
    if (user_is_root) ; then
        ERR="Do not run this as root or sudo"
    fi
fi


# Module name
if [[ $ERR == "" ]]; then
    MOD=${1}
    
    SRCDIR="$PROJ_ROOT/src"

    _MOD_CHK=`echo $MOD | sed 's/\s*//g' | sed 's/\\n//g'`
    if [[ "$MOD" != "$_MOD_CHK" ]]; then # No spaces etc.
        ERR="Module must not have spaces in name. Got: \'$MOD\'"

    elif [[ "$MOD" == "" ]]; then # Not empty
        ERR="Module variable must not be blank!"

    elif [ ! -d "$SRCDIR" ]; then
        ERR="src directory not found: \'$SRCDIR\'"

    elif [ ! -d "$SRCDIR/$MOD" ]; then # verify pwd and mod is correct
        ERR="This script must be run from project root (parent of src)"

    fi
fi


# Bin path
if [[ $ERR == "" ]]; then
    BINPATH=$2
    # remove trailing slash
    BINPATH=$(dirname "$BINPATH/x")
    # verify path exists
    if [ ! -d "$BINPATH" ]; then
        ERR="Directory ($BINPATH) does not exist. Please create if needed"
    fi
fi

# Check alternate includes
if [[ $ERR == "" ]]; then
    ALT_INCL_STR=""
    ALTINCL_ALL=$3
    
    if [[ "$ALTINCL_ALL" != "" ]]; then
        readarray -d , -t INCL_PATHS<<< "$ALTINCL_ALL"
        

        for ((i=${#INCL_PATHS[@]}-1; i>=0; i--)); do
            INCL_PATH=${INCL_PATHS[$i]}
            INCL_PATH=`echo $INCL_PATH | sed 's/\s*//g' | sed 's/\\n//g'`
            
            if [[ $ERR == "" ]]; then
                # Verify each path
                INCL_PATH_FULL=$PROJ_ROOT/$INCL_PATH
                if [ ! -d $INCL_PATH_FULL ]; then # verify incl directory exists
                    ERR="Include directory provided ($INCL_PATH_FULL) does not exist"
                else
                    ALT_INCL_STR="\$PROJ_ROOT/${INCL_PATH}:${ALT_INCL_STR}"
                    # echo \'$ALT_INCL_STR\'
                fi
            fi
        done
    fi
fi


# Verify exe (don't clobber)
if [[ $ERR == "" ]]; then
    BINPATH_FULL=$BINPATH/$MOD
    if [ -f "$BINPATH_FULL" ]; then # don't clobber
        ERR="Module executable $BINPATH_FULL already exists. Please remove first before running"
    fi
fi

SUDO=0
write_line () { 
    if [ $SUDO -eq "1" ]; then
        echo $1 | sudo tee -a "$BINPATH_FULL" >/dev/null
    else
        echo $1 | tee -a "$BINPATH_FULL" >/dev/null
    fi
}

# Create executable
if [[ $ERR == "" ]]; then

    # touch file
    if [ ! -w "$BINPATH" ]; then
        SUDO=1
        echo "About to create script $BINPATH_FULL. May need pwd..."
        sudo touch "$BINPATH_FULL"
    else
        touch "$BINPATH_FULL"
    fi

    write_line "PROJ_ROOT=$PROJ_ROOT"
    
    # PYTHONPATH (if applicable)
    if [[ "$ALT_INCL_STR" != "" ]]; then
        write_line "export PYTHONPATH=$ALT_INCL_STR\$PYTHONPATH"
    fi

    # run.sh
    write_line "$HOME/.py_src_run/run.sh \"\$PROJ_ROOT/src\" $MOD \"\$@\""

    # chmod +x
    if [ $SUDO -eq "1" ]; then
        sudo chmod a+x "$BINPATH_FULL"
    else
        chmod a+x "$BINPATH_FULL"
    fi

    echo "Executable created: $BINPATH_FULL"

else
    echo "make_mod_exe.sh failed - $ERR"
    echo " . CLI Args: \'$@\'"
fi