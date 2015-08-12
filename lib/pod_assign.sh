#!/bin/bash
# Assign a pod to a NETLAB user

# Initial values, some may be replaced depending on parameters
CURL=`which curl`

function usage {
	echo "Usage: $0 --podid ID --classid ID --userid ID --host HOST --cookie COOKIE"
}

while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--podid)
		POD_ID="$2"
		shift
		;;

		--classid)
		CLASS_ID="$2"
		shift
		;;

		--userid)
		USER_ID="$2"
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
if [ -z "${CLASS_ID}" ]; then
	echo "--classid is required"
	usage
	exit 1
fi
if [ -z "${USER_ID}" ]; then
	echo "--userid is required"
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
"${CURL}" -s "${HOST}/pod_assign.cgi" \
-H "Cookie: netlab_sid=${COOKIE}" \
-H "Origin: ${HOST}" \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryBUpJUIMbnuoGA38J' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Cache-Control: max-age=0' \
-H "Referer: ${HOSt}/pod_assign.cgi" \
-H 'Connection: keep-alive' \
--data-binary $'------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="_state"\r\n\r\nadd_submit\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="layer"\r\n\r\nSYS\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="com_id"\r\n\r\n\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="div_id"\r\n\r\n\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="cls_id"\r\n\r\n\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="pod_id"\r\n\r\n'"${POD_ID}"$'\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="confirm"\r\n\r\n0\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="form_com_id"\r\n\r\n1\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="form_cls_id"\r\n\r\n'"${CLASS_ID}"$'\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J\r\nContent-Disposition: form-data; name="form_acc_id"\r\n\r\n'"${USER_ID}"$'\r\n------WebKitFormBoundaryBUpJUIMbnuoGA38J--\r\n' \
--compressed > /dev/null
