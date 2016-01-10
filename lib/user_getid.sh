#!/bin/bash
# Get the NETLAB ID of the Student

# Initial values, some may be replaced depending on parameters
CURL=`which curl`

function usage {
	echo "Usage: $0 --username NAME --host HOST --cookie COOKIE"
}

while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--username)
		USER_NAME="$2"
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
if [ -z "${USER_NAME}" ]; then
	echo "--username is required"
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

# Perform request, save HTML into output
output=`"${CURL}" -s "${HOST}/accman.cgi" \
-H "Cookie: cookie_test=1438784559; netlab_sid=${COOKIE}; PHPSESSID=8bf475295ce3d696c70c23093c99b770" \
-H "Origin: ${HOST}" \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Cache-Control: max-age=0' \
-H "Referer: ${HOST}/accman.cgi" \
-H 'Connection: keep-alive' \
--data 'State=Search&from_query=1&community_id=0&type_filter=A&query_filter=' \
--compressed`

# Determine which version of grep to use based on OS X or Linux!
grep -V | grep "BSD" > /dev/null 2>&1
if [ "$?" == 0 ]; then
	grep="grep -Eo"
else
	grep="grep -Po"
fi

# Massage the data in output and find the acc_id
echo "${output}" | grep -i "${USER_NAME}<" -B 2 | head -n 1 | grep "javascript:show_account" | ${grep} "[0-9]+"

exit "$?"
