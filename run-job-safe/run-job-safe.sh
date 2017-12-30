#!/bin/bash
#

###
# Overview
# - This script wraps a process and prevents multiple occurances of the
#   process from running by saving the script's PID in a file
# - Script runs a process and exits when that process is finished
# - A pid file is created while the process runs with the PID of this script


BASE_DIR=~
# Define file where PID is kept -- should not be in tmp directories
PID_FILE=${BASE_DIR}/run-job-safe.pid
# Executable we want to run
EXEC_CMD="python ${BASE_DIR}/test.py"
# Env vars file to source when running the process - if we're using crontab
#   then env will be mostly empty so we need to provide context
ENV_VARS_FILE=${BASE_DIR}/env.sh


# Check if PID file present, if it is, then process running, so don't
#   try to run again
if [ -f $PID_FILE ]
then
    # See if PID in pid file matches a running process -- print results
    PID_F=$(cat $PID_FILE)
    ps -p $PID_F > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo "Process ${PID_F} already running"
        exit 1
    else
        echo "Process ${PID_F} in ${PID_FILE} not found - exec error - exiting"
        exit 1
    fi
else
    # If PID file not present, then create the PID file by writing the PID
    #   of this shell script into it
    echo $$ > $PID_FILE
    if [ $? -ne 0 ]
    then
        echo "Could not create pid file"
        exit 1
    fi
fi

# Source env vars
source $ENV_VARS_FILE
# Run process
$EXEC_CMD

# Process finished so remove pid file
rm $PID_FILE
