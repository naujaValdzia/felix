#!/bin/bash

#define environment variables 
export FELIX_SYSTEM_NAME=$1
PF=/usr/db/felixdb.pf
export DLC=/usr/dlc
export CURRENT_DIR="$(pwd)"
export TEMP=/tmp

#Define propath
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_core"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_core/src/prog/util"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_core/src/prog/system"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_core/src/prog/analysis"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_core/src/scripts"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_core/src/prog/trigger"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_shared/system/dto"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_shared/system/i"
export PROPATH="$PROPATH:$DLC/servers/pasoe/felix/dev/felix_shared/analysis/i"

echo [1] Initializing system setup
echo [2] System is now creating .db file and loading data from .df and .st

echo [3] System is now generating Xref files
_progres -b -p ../prog/analysis/systemFind.p -pf "$PF"
wait
echo Xref compilation is now complete. Proceeding.

echo [4] System is now searching for errors that may have occurred while generating Xref files.
_progres -b -p ../prog/analysis/systemError.p -pf "$PF"
wait
echo Search complete

echo [5] Starting Xref analysis...
_progres -b -p ../prog/analysis/xrefAnalysis.p -pf "$PF"
wait
echo Xref analysis complete
echo Go back to localhost:4530 to view analysis results
echo [DONE] Setup complete
