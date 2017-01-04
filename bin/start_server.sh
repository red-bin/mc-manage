#!/bin/bash

function exit_early { echo "[ERROR] $@" ; exit 1 ; }

function setup_ramdisk {
    if [ -e "$HOTDIR" ] ; then
        read -p "Wipe anything at ($HOTDIR) and copy data from disk ($COLDDIR)?" prompt

        if [[ "$prompt" =~ [Yy] ]] ; then
            rsync -av --delete $HOTDIR $BACKUPDIR/hot_backup/
            rsync -av --delete $COLDDIR $RAMDISK
        fi
    else
        rsync -av --delete $COLDDIR $RAMDISK
    fi
   
}

function start_command {
    perf_wrapper 
    java_command
}

function check_running { 
    screen -list $INSTANCENAME | grep -q "There is a screen on" \
      && exit_early "Already running. Kill it with \`mc_manage stop\`. Quitting." \
      || echo "$INSTANCENAME not already running. Continuing.."
}
function start_server { 
    #echo -e `start_command`
    screen -dmS $INSTANCENAME bash -c "cd $HOTDIR ; `start_command` ; screen -X -S $INSTANCENAME kill ; exec bash ; " 
}

[ ! -e /opt/minecraft/current.cfg ] \
  && /opt/minecraft/bin/init_server.sh

source /opt/minecraft/bin/start_builder.sh
source /opt/minecraft/config

check_running
setup_ramdisk
#$BINDIR/environment_checks.sh
start_server

echo "Server starting. To watch startup: "
echo "tail -f $LOGDIR/latest.log"
