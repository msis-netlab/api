#!/bin/bash
# Delete a Pod from NETLAB

# !!!!!!!!!! THIS CALLS pod_delete_tx.sh !!!!!!!!!!

# Initial values, some may be replaced depending on parameters
CURL=`which curl`

function usage {
	echo "Usage: $0 --podid ID --host HOST --cookie COOKIE"
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

# Determine which version of grep to use based on OS X or Linux!
grep -V | grep "BSD" > /dev/null 2>&1
if [ "$?" == 0 ]; then
	grep="grep -Eo"
else
	grep="grep -Po"
fi

# Determine _tx value
dir=`echo "$0" | ${grep} "^.*/"`
tx=`${dir}/pod_delete_gettx.sh --podid "${POD_ID}" --host "${HOST}" --cookie "${COOKIE}"`

"${CURL}" -s "${HOST}/pod_delete.cgi" \
-H "Cookie: netlab_sid=${COOKIE}" \
-H 'Origin: http://netlab.netlab-domain' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryUeMbDlwyky8KvCFk' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Cache-Control: max-age=0' \
-H "Referer: ${HOST}/pod_delete.cgi" \
-H 'Connection: keep-alive' \
--data-binary $'------WebKitFormBoundaryUeMbDlwyky8KvCFk\r\nContent-Disposition: form-data; name="_state"\r\n\r\ndelete\r\n------WebKitFormBoundaryUeMbDlwyky8KvCFk\r\nContent-Disposition: form-data; name="pod_id"\r\n\r\n'"${POD_ID}"$'\r\n------WebKitFormBoundaryUeMbDlwyky8KvCFk\r\nContent-Disposition: form-data; name="State"\r\n\r\nshow\r\n------WebKitFormBoundaryUeMbDlwyky8KvCFk\r\nContent-Disposition: form-data; name="_tx"\r\n\r\n'"${tx}"$'\r\n------WebKitFormBoundaryUeMbDlwyky8KvCFk\r\nContent-Disposition: form-data; name="delete_vm_option"\r\n\r\nDISK\r\n------WebKitFormBoundaryUeMbDlwyky8KvCFk--\r\n' \
--compressed > /dev/null &

exit "$?"
