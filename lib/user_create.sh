#!/bin/bash

#!/bin/bash
# Create a user in NETLAB -- for now, only Student types

# Initial values, some may be replaced depending on parameters
CURL=`which curl`
PASSWORD='pa$$word'

function usage {
	echo "Usage: $0 --username NAME --firstname NAME --lastname NAME --host HOST --cookie COOKIE [--password PASSWORD] [--email EMAIL]"
}
function log {
	echo "[`date` -- $0]  $1"
}

while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--username)
		USERNAME="$2"
		shift
		;;

		--firstname)
		FIRSTNAME="$2"
		shift
		;;

		--lastname)
		LASTNAME="$2"
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

		--password)
		PASSWORD="$2"
		shift
		;;

		--email)
		EMAIL="$2"
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
	echo "--username is required"
	usage
	exit 1
fi
if [ -z "${FIRSTNAME}" ]; then
	echo "--firstname is required"
	usage
	exit 1
fi
if [ -z "${LASTNAME}" ]; then
	echo "--lastname is required"
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

"${CURL}" -s "${HOST}/accman.cgi" \
-H "Cookie: netlab_sid=${COOKIE}" \
-H "Origin: ${HOST}" \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Cache-Control: max-age=0' \
-H "Referer: ${HOST}/accman.cgi" \
-H 'Connection: keep-alive' \
--data "State=Add_Submit&add_max=10&cls_id=&imported=0&community_id=1&init_pass=${PASSWORD}&retype_pass=${PASSWORD}&name_gen_enable=1&name_gen_type=0&display_name_format=0&user_1=${USERNAME}&gname_1=${FIRSTNAME}&fname_1=${LASTNAME}&dname_1=${FIRSTNAME}+${LASTNAME}&type_1=S&email_1=${EMAIL}&user_2=&gname_2=&fname_2=&dname_2=&type_2=S&email_2=&user_3=&gname_3=&fname_3=&dname_3=&type_3=S&email_3=&user_4=&gname_4=&fname_4=&dname_4=&type_4=S&email_4=&user_5=&gname_5=&fname_5=&dname_5=&type_5=S&email_5=&user_6=&gname_6=&fname_6=&dname_6=&type_6=S&email_6=&user_7=&gname_7=&fname_7=&dname_7=&type_7=S&email_7=&user_8=&gname_8=&fname_8=&dname_8=&type_8=S&email_8=&user_9=&gname_9=&fname_9=&dname_9=&type_9=S&email_9=&user_10=&gname_10=&fname_10=&dname_10=&type_10=S&email_10=" \
--compressed > /dev/null

if [ "$?" != 0 ]; then
	log "FAILURE: Could not create Student: ${USERNAME}, ${FIRSTNAME}, ${LASTNAME}: curl exit code: $?"
	exit 1
fi

log "SUCCESS: Created Student: ${USERNAME}, ${FIRSTNAME}, ${LASTNAME}"

exit 0
