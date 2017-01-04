#!/bin/bash

source /opt/minecraft/config

IFS="
"

instances=`ls -1 $BASEDIR/instances`
echo -e "$instances" | grep -n . | sed 's/:/: /'

read -p "Which instance? " prompt_answer
current_instance=`echo -e "$instances" | sed "${prompt_answer}q;d"`

jars=`ls -1 $BASEDIR/instances/$current_instance/*jar`
echo -e "$jars" | grep -n . | sed 's/:/: /'

read -p "Which jar? " prompt_answer
current_jar=`echo -e "$jars" | sed "${prompt_answer}q;d"`

jarfile=`basename $current_jar`

echo "JAR=\$HOTDIR/$jarfile" > /opt/minecraft/current.cfg
echo "INSTANCENAME=$current_instance" >> /opt/minecraft/current.cfg
