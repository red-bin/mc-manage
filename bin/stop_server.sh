#!/bin/bash

source /opt/minecraft/config
source /opt/minecraft/current.cfg



function copy_hot {
    read -p "Wipe anything at ($HOTDIR) and copy data from disk ($COLDDIR)?" prompt

    if [[ "$prompt" =~ [Yy] ]] ; then
        rsync -av --delete $COLDDIR $BACKUPDIR/cold_backup/
        rsync -av --delete $HOTDIR/ $COLDDIR/
    fi
}

function still_running {
    screen -list $INSTANCENAME | grep -q "There is a screen on" \
      && echo "Still running...." || ( echo "It's down!" ; return 1 ;)
}

echo "Stopping instance: $INSTANCENAME."

#Wait for screen session to die.
while [ 1 -eq 1 ] ; do 
    still_running || break
    screen -S $INSTANCENAME -p 0 -X stuff "stop^M"
    sleep 2 
done

copy_hot >> /opt/minecraft/backups/log
