#!/bin/bash
# Brings a pod offline in NETLAB

function usage {
	echo "Usage: $0 --podid ID --host HOST --cookie COOKIE [--devid ID] [--pcid ID]"
}

# Initial values, some may be replaced depending on parameters
CURL=`which curl`
DEV_ID="undefined"	# Not sure what these two parameters are for but they are present in the request to bring a pod online so I am including them
PC_ID="0"

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

# Attempt to bring the pod online
"${CURL}" -s "${HOST}/conf_pods.cgi" \
-H "Cookie: cookie_test=1438308112; netlab_sid=${COOKIE}; PHPSESSID=8bf475295ce3d696c70c23093c99b770" \
-H "Origin: ${HOST}" \
-H "Accept-Encoding: gzip, deflate" \
-H "Accept-Language: en-US,en;q=0.8" \
-H "Content-Type: application/x-www-form-urlencoded" \
-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
-H "Cache-Control: max-age=0" \
-H "Referer: ${HOST}/conf_pods.cgi?State=show&pod_id=${POD_ID}" \
-H "Connection: keep-alive" \
--data "State=pod_offline&pod_id=${POD_ID}&dev_id=${DEV_ID}&pc_id=${PC_ID}" \
--compressed > /dev/null 2>&1

echo "$?"
