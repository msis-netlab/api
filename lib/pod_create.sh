#!/bin/bash
# Clone an existing pod in order to create a new pod in NETLAB

# Initial values, some may be replaced depending on parameters
CURL=`which curl`

function usage {
	echo "Usage: $0 --sourcepodid ID --clonepodid ID --clonepodname NAME --data DATA --host HOST --cookie COOKIE [--clonetype TYPE] [--clonerole ROLE]"
}


while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--sourcepodid)
		SOURCE_POD_ID="$2"
		shift
		;;

		--clonepodid)
		CLONE_POD_ID="$2"
		shift
		;;

		--clonepodname)
		CLONE_POD_NAME="$2"
		shift
		;;

		--data)
		DATA="$2"
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

		--clonetype)
		CLONE_TYPE="$2"
		shift
		;;

		--clonerole)
		CLONE_ROLE="$2"
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

# Required arguments
if [ -z "${SOURCE_POD_ID}" ]; then
	usage
	exit 2
fi

if [ -z "${CLONE_POD_ID}" ]; then
	usage
	exit 3
fi

if [ -z "${CLONE_POD_NAME}" ]; then
	usage
	exit 4
fi

if [ -z "${DATA}" ]; then
	usage
	exit 4
fi

if [ -z "${HOST}" ]; then
	usage
	exit 4
fi

if [ -z "${COOKIE}" ]; then
	usage
	exit 4
fi

# JSON header
foo="{
	\"jsonrpc\": \"2.0\",
	\"method\": \"pod.clone.task\",
	\"params\": {
		\"source_pod_id\": \"${SOURCE_POD_ID}\",
		\"clone_pod_id\": \"${CLONE_POD_ID}\",
		\"clone_pod_name\": \"${CLONE_POD_NAME}\",
		\"pc_clone_specs\": ["


# JSON params body (spin through $DATA)
while read line; do
	foo+="
			{
				\"pl_index\": \"`echo ${line} | awk -F\| '{print $1}'`\",
				\"pc_type\": \"`echo ${line} | awk -F\| '{print $2}'`\",
				\"source_vm_id\": \"`echo ${line} | awk -F\| '{print $3}'`\",
				\"source_snapshot\": \"`echo ${line} | awk -F\| '{print $4}'`\",
				\"clone_name\": \"`echo ${line} | awk -F\| '{print $5}'`\",
				\"clone_type\": \"`echo ${line} | awk -F\| '{print $6}'`\",
				\"clone_role\": \"`echo ${line} | awk -F\| '{print $7}'`\",
				\"clone_datastore\": \"`echo ${line} | awk -F\| '{print $8}'`\",
				\"clone_storage_alloc\": \"`echo ${line} | awk -F\| '{print $9}'`\",
				\"clone_vh_id\": \"`echo ${line} | awk -F\| '{print $10}'`\"
			},"
done <<< "${DATA}"

# Remove the last comma to match JSON syntax -- s/},/}/ -- and add JSON footer
wc=`echo "${foo}" | wc -l`
foo=`echo "${foo}" | head -n $((wc-1))`
foo+="
			}
		]
	},
	\"id\": null
}"

# POST the JSON block
"${CURL}" -s "${HOST}/api/jsonrpc.cgi?method" \
-H "Cookie: netlab_sid=${COOKIE}" \
-H "Origin: ${HOST}/" \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json, text/javascript, */*; q=0.01' \
-H "Referer: ${HOST}/clone_pod.cgi" \
-H 'X-Requested-With: XMLHttpRequest' \
-H 'Connection: keep-alive' \
--data-binary $"${foo}" \
--compressed

exit "$?"
