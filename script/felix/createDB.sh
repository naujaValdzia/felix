#!/bin/bash
LOG=/usr/db/db.log
PF=/usr/db/felixdb.pf
DF=$DLC/servers/pasoe/felix/dev/felix_shared/db/felixdb.df
DB_PATH=/usr/db

#create PF
echo "-db $DB_PATH/felixdb.db -S 14440" > "$PF"

if [ ! -f "$DB_PATH"/felixdb.db ]
then
	#create empty DB
	prodb "$DB_PATH"/felixdb.db empty
	proserve -pf "$PF"
	
	#load DF
	_progres -b -p "/usr/dlc/servers/pasoe/felix/dev/felix_core/src/scripts/loadDF.p" -param "$DF" -pf "$PF" >> "$LOG"
else
	proserve -pf "$PF"
fi

echo $(date) 'DB started' >> "$LOG"

