#!/bin/bash

function exit_early { echo "[ERROR] $@" ; exit 1 ; }
function error_log { echo "[ERROR]" $@ ; }
function warn_log { echo "[WARNING]" $@ ; }

source /opt/minecraft/config || exit_early "Could not load /opt/minecraft/config"
source /opt/minecraft/current.cfg || exit_early "Could not load /opt/minecraft/current.cfg"

REQ_VARS="BASEDIR BINDIR BACKUPDIR RAMDISK COLDDIR HOTDIR LOGDIR JAR"

function is_tmpfs {
    df --type tmpfs $RAMDISK &>/dev/null || return 1
}

function check_user {
    [[ `whoami` == "minecraft" ]] \
      || (error_log "Needs to be run as minecraft user" ; \
          return 1)
}

function is_set { 
     [ "${!1}" ] \
      || (error_log "$1 (${!1}) not set as an environment variable" ; \
          return 1)
}

function is_absolute { 
    [[ "${!1}" == /* ]] \
      || (error_log "$1 (${!1}) not an absolute path" ; \
          return 1)
}

function exists { 
    [ -e "${!1}" ] \
      || (error_log "$1 (${!1}) does not exist" ; \
          return 1)
}

function check_ownership {
    local return_code=0
    path="${!1}"

    perms=`ls -ld $path | awk '{print $3":"$4}'`

    [[ "$perms" == "minecraft:minecraft" ]] \
      || (error_log "$path is owned by $perms. Should be minecraft" ; \
          return_code=1)

    return $return_code
}

function check_path {
    local return_code=0
    is_set $1 || return_code=1
    is_absolute $1 || return_code=1
    exists $1 || return_code=1

    return $return_code
}

function check_config_paths {
    local return_code=0
    config_paths="$REQ_VARS"

    for config_path in $config_paths ; do
        check_path $config_path || return_code=1
    done
    return $return_code
}

function check_ownerships {
    local return_code=0
    minecraft_paths="BASEDIR LOGDIR RAMDISK APPDIR BACKUPDIR JARFILE"
    for path in $minecraft_paths ; do 
        check_ownership $path || return_code=1
    done
    return $return_code
}

function java_exists {
    which java &>/dev/null \
      || (error_log "Java is not installed." || return 1)
}

function java_version {
    #looks like: 'openjdk version "1.8.0_111"'

    version=$1
    java -version 2>&1 | awk '$NF ~ /"'$version'.*"/' \
      | grep -q . || (error_log "Java must be 1.8 or higher" ; return 1)
}

function check_java {
    local return_code=0

    java_exists || return_code=1
    java_version 1.8 || return_code=1
}

function check_ramdisk {
    is_tmpfs $RAMDISK || (error_log "Ramdisk path is not tmpfs" ; return 1)
}

function check_config {
    local return_code=0

    check_config_paths || return_code=1
    check_ownerships || return_code=1
    return $return_code
}

check_ramdisk || exit_early "Ramdisk not configured properly. Run /opt/minecraft/bin/run_as_root.sh"
check_config || exit_early "Config not configured properly"
check_java || exit_early "Java not configured properly"

echo "Config looks good."
