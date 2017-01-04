#!/bin/bash

function set_mtu {
    tail -n +3 /proc/net/dev \
      | sed -r 's/^ *([^:]*).*/\1/' \
      | egrep -v "^lo$" \
      | xargs -I{} \
          ifconfig {} mtu 9000
}

function set_governor { 
    seq 0 7 | xargs -I{} cpufreq-set -g performance -c{} ; 
}


function hugepages { 
    echo "Setup hugepages, dammit!"
    #echo 512 > /proc/sys/vm/nr_hugepages
}

function mem_perf {
    swapoff -a
}

function iface_perf {
    set_mtu
}

function cpu_perf {
    mkdir /sys/fs/cgroup/cpuset/minecraft
    echo 1-3,5-7 > /sys/fs/cgroup/cpuset/minecraft/cpuset.cpus
    chown -R minecraft:minecraft /sys/fs/cgroup/cpuset/minecraft
    set_governor
}

function tmpfs_opts {
    printf " nodev,nosuid,noexec,nodiratime,size=32768M,mpol=interleave"
}

function mount_ramdisk { 
    echo "Mounting ramdisk to $RAMDISK"
    mount -t tmpfs -o `tmpfs_opts` tmpfs $RAMDISK 
    chown minecraft:minecraft "$RAMDISK"
    echo "Ramdisk mounted."
}

function perf_changes {
    echo "Making perf changes!"

    cpu_perf 
    iface_perf 
    hugepages
    mem_perf
}
