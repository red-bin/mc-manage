#!/bin/bash

if [ "$USER" != "root" ] ; then 
    echo "You must be root. Exiting" 
    exit 1
fi

source /opt/minecraft/config
source $BINDIR/root_functions.sh

mount_ramdisk 
perf_changes
