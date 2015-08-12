#!/bin/bash
# Get the NETLAB ID of the Pod

# Initial values, some may be replaced depending on parameters
CURL=`which curl`

function usage {
	echo "Usage: $0 --podname NAME --host HOST --cookie COOKIE"
}

while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--podname)
		POD_NAME="$2"
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
if [ -z "${POD_NAME}" ]; then
	echo "--podname is required"
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
output=`"${CURL}" -s "${HOST}/conf_pods.cgi" \
-H 'Accept-Encoding: gzip, deflate, sdch' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H "Cookie: cookie_test=1438784559; netlab_sid=${COOKIE}; PHPSESSID=8bf475295ce3d696c70c23093c99b770" \
-H 'Connection: keep-alive' \
--compressed`


# Massage the HTML response to focus on POD_NAME
pod_id=`echo "${output}" | grep -i "${POD_NAME}" -B 4 | head -n 1 | grep -o "pod_id=[0-9]*" | sed 's/pod_id=//'`

# If pod_id is not set, exit -1
if [ -z "${pod_id}" ]; then
	exit -1
fi
echo "${pod_id}"
exit 0
