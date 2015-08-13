#!/bin/bash
# Get the NETLAB ID of the Class

# Initial values, some may be replaced depending on parameters
CURL=`which curl`

function usage {
	echo "Usage: $0 --classname NAME --host HOST --cookie COOKIE"
}

while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--classname)
		CLASS_NAME="$2"
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
if [ -z "${CLASS_NAME}" ]; then
	echo "--classname is required"
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
-H "Cookie: cookie_test=1438784559; netlab_sid=${COOKIE}; PHPSESSID=8bf475295ce3d696c70c23093c99b770" \
-H 'Connection: keep-alive' \
--compressed`


# Determine which version of grep to use based on OS X or Linux!
grep -V | grep "BSD" > /dev/null 2>&1
if [ "$?" == 0 ]; then
	grep="grep -Eo"
else
	grep="grep -Po"
fi

# Massage the HTML response to focus on CLASS_NAME
class_id=`echo "${output}" | grep -Ei "^${CLASS_NAME}<" -B 2 | grep "javascript:OnClassSelect" | head -n 1 | ${grep} "[0-9]+"`

# If class_id is not set return -1
if [ -z "${class_id}" ]; then
	exit -1
fi
echo "${class_id}"

exit "$?"
