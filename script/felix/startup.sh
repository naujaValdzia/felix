#!/bin/bash

sleep infinity &

trap clean INT SIGINT SIGTERM

LOG="startup.log"

function clean() {
	echo $(date) 'Stopping database...' >> "$LOG"
	$DLC/servers/pasoe/felix/dev/felix_core/src/scripts/stopDB.sh
}

$DLC/servers/pasoe/felix/dev/felix_core/src/scripts/createDB.sh 2>/dev/null
$DLC/servers/pasoe/felix/bin/tcman.sh start 2>/dev/null
#/bin/bash 2>/dev/null

npm start --prefix $DLC/servers/pasoe/felix/dev/felix_front/felix &

echo $(date) 'Waiting...' >> "$LOG"

wait $!
