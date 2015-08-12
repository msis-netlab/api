#!/bin/bash
# Add users to NETLAB, with their own pods, for IS6640 Fall 2015

function usage {
	echo "Usage: $0 --username NAME --classname NAME --clonepodid ID --sourcepodid ID --host HOST --cookie COOKIE"
}

while [[ $# > 1 ]]; do
	key="$1"

	case "$key" in
		--username)
		USERNAME="$2"
		shift
		;;

		--classname)
		CLASS_NAME="$2"
		shift
		;;

		--clonepodid)
		CLONE_POD_ID="$2"
		shift
		;;

		--sourcepodid)
		SOURCE_POD_ID="$2"
		shift
		;;

		--host)
		HOST="$2"
		shift
		;;

		--cookie)
		COOKIE="$2"
		shift
		;;

		*)
		# Unknown option
		echo "Unknown option: $key"
		usage
		exit 1
		;;
	esac
	shift
done

# Required arguments -- exit if not present
if [ -z "${USERNAME}" ]; then
	usage
	exit 1
fi
if [ -z "${CLASS_NAME}" ]; then
	usage
	exit 1
fi
if [ -z "${CLONE_POD_ID}" ]; then
	usage
	exit 1
fi
if [ -z "${SOURCE_POD_ID}" ]; then
	usage
	exit 1
fi
if [ -z "${HOST}" ]; then
	usage
	exit 1
fi
if [ -z "${COOKIE}" ]; then
	usage
	exit 1
fi

# Determine which version of grep to use based on OS X or Linux!
grep -V | grep "BSD" > /dev/null 2>&1
if [ "$?" == 0 ]; then
	grep="grep -Eo"
else
	grep="grep -Po"
fi

# Determine the context of the call
dir=`echo "$0" | ${grep} "^.*/"`

# 0) Pod - Get info
DATA=`${dir}/lib/pod_getinfo.sh --clonepodid "${CLONE_POD_ID}" --clonepodname "${CLASS_NAME} - ${USERNAME}" --sourcepodid "${SOURCE_POD_ID}" --host "${HOST}" --cookie "${COOKIE}"`

# 1) Pod - Create
${dir}/lib/pod_create.sh --sourcepodid "${SOURCE_POD_ID}" --clonepodid "${CLONE_POD_ID}" --clonepodname "${CLASS_NAME} - ${USERNAME}" --data "${DATA}" --host "${HOST}" --cookie "${COOKIE}"

# 2) Pod - Assign - Get user id
userid=`${dir}/lib/user_getid.sh --username "${USERNAME}" --host "${HOST}" --cookie "${COOKIE}"`

# 3) Pod - Assign - Get class id
classid=`${dir}/lib/class_getid.sh --classname "${CLASS_NAME}" --host "${HOST}" --cookie "${COOKIE}"`

# 4) Pod - Assign
${dir}/lib/pod_assign.sh --podid "${CLONE_POD_ID}" --classid "${classid}" --userid "${userid}" --host "${HOST}" --cookie "${COOKIE}"

# 5) Pod - Online
${dir}/lib/pod_online.sh --podid "${CLONE_POD_ID}" --host "${HOST}" --cookie "${COOKIE}"

# 6) Pod - Get id
${dir}/lib/pod_getid.sh --podname "${CLASS_NAME} - ${USERNAME}" --host "${HOST}" --cookie "${COOKIE}"
