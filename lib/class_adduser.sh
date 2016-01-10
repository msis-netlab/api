#!/bin/bash
# Add specific user to class

# Initial values, some may be replaced depending on parameters
CURL=`which curl`

function usage {
	echo "Usage: $0 --userid ID --classid ID --host HOST --cookie COOKIE"
}

while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--userid)
		USER_ID="$2"
		shift
		;;

		--classid)
		CLASS_ID="$2"
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
if [ -z "${USER_ID}" ]; then
	echo "--userid is required"
	usage
	exit 1
fi
if [ -z "${CLASS_ID}" ]; then
	echo "--classid is required"
	usage
	exit 1
fi
if [ -z "${HOST}" ]; then
	echo "--host is required"
	usage
	exit 1
fi
if [ -z "${COOKIE}" ]; then
	echo "--cookie is required"
	usage
	exit 1
fi






# Perform GET, save to local variable
output=`"${CURL}" -s "${HOST}/class.cgi" \
-H 'Accept-Encoding: gzip, deflate, sdch' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H "Cookie: netlab_sid=${COOKIE}" \
-H 'Connection: keep-alive' \
--data "State=add_select_submit&cls_id=${CLASS_ID}&acc_id=${USER_ID}" \
--compressed`


# This needs to be modified to fail if a user already belongs to a class
if [ "$?" != 0 ]; then
        echo "FAILURE: Could not add Student to Class: ${USER_ID}, ${CLASS_ID}: curl exit code: $?"
        exit 1
fi

echo "SUCCESS: Added Student ID: ${USER_ID} to Class ID: ${CLASS_ID}"

exit 0
