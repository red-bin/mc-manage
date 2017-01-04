#!/bin/bash

source /opt/minecraft/config
source /opt/minecraft/current.cfg

function jvm_gc {
    printf " -XX:+UseG1GC -XX:+DisableExplicitGC  -XX:TargetSurvivorRatio=90"
    printf " -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=50" 
}

function jvm_mem {
    printf " -Xmx14336m -Xms14336m -XX:InitiatingHeapOccupancyPercent=10 "
   # printf " -XX:+UseLargePages" #-XX:+UseLargePagesInMetaspace "
}

function jvm_logging {
    printf " -verbose:gc -Xloggc:${LOGDIR}/gc.log "
    printf " -XX:+PrintGCDetails -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"
}

function jvm_monitoring {
    printf " -Dcom.sun.management.jmxremote "
    printf " -Dcom.sun.management.jmxremote.port=9010 "
    printf " -Dcom.sun.management.jmxremote.local.only=true "
    printf " -Dcom.sun.management.jmxremote.authenticate=false "
    printf " -Dcom.sun.management.jmxremote.ssl=false "
}

function jvm_extras {
    printf " -XX:+UseStringDeduplication -XX:+UseNUMA -XX:+AlwaysPreTouch -server"
    printf " -XX:+UnlockExperimentalVMOptions -XX:+AggressiveOpts"
}

function java_suffix { printf " -jar $JAR nogui" ; } 

function java_command { 
    printf "java"
    jvm_mem
    jvm_extras
    jvm_gc
    jvm_logging
    #jvm_monitoring
    java_suffix
}

function perf_wrapper { 
    #printf " chrt -r 10 taskset -ac 1,2,3,5,6,7 numactl --interleave=all " 
    printf " numactl --interleave=all " 
}
