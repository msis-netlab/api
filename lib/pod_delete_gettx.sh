#!/bin/bash
# In order to delete a pod, a parameter "_tx" must be known.

# !!!!!!!!!! THIS IS CALLED BY pod_delete.sh !!!!!!!!!!

# Initial values, some may be replaced depending on parameters
CURL=`which curl`
DEV_ID="0"
PC_ID="0"

function usage {
	echo "Usage: $0 --podid ID --host HOST --cookie COOKIE [--devid ${DEV_ID}] [--pcid ${PC_ID}]"
}

while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--podid)
		POD_ID="$2"
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

		--devid)
		DEV_ID="$2"
		shift
		;;

		--pcid)
		PC_ID="$2"
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
if [ -z "${POD_ID}" ]; then
	echo "--podid is required"
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

output=`"${CURL}" -s "${HOST}/pod_delete.cgi" \
-H "Cookie: cookie_test=1438308112; netlab_sid=${COOKIE}; PHPSESSID=8bf475295ce3d696c70c23093c99b770" \
-H "Origin: ${HOST}" \
-H "Accept-Encoding: gzip, deflate" \
-H "Accept-Language: en-US,en;q=0.8" \
-H "Content-Type: application/x-www-form-urlencoded" \
-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
-H "Cache-Control: max-age=0" \
-H "Referer: ${HOST}/conf_pods.cgi?State=show&pod_id=${POD_ID}" \
-H "Connection: keep-alive" \
--data "State=&pod_id=${POD_ID}&dev_id=${DEV_ID}&pc_id=${PC_ID}" \
--compressed`

# Determine which version of grep to use based on OS X or Linux!
grep -V | grep "BSD" > /dev/null 2>&1
if [ "$?" == 0 ]; then
	grep="grep -Eo"
else
	grep="grep -Po"
fi

# Massage data to get "_tx"
echo "${output}" | grep "_tx" | ${grep} "value=\"[0-9]*\"" | sed 's/value=//' | sed 's/"//g'

exit "$?"
