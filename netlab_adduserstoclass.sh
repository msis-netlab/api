#!/bin/bash

HOST=netlab.netlab-domain
COOKIE=
CLASSNAME=""
CLASSID=`lib/class_getid.sh --classname "${CLASSNAME}" --host $HOST --cookie $COOKIE`
echo $CLASSID

for username in ``; do
	userid=`lib/user_getid.sh --username $username --host $HOST --cookie $COOKIE`;
	echo $userid;
	lib/class_adduser.sh --userid $userid --classid $CLASSID --host $HOST --cookie $COOKIE;
done
