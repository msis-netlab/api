#!/bin/bash
# Get all information about a Pod in NETLAB in preparation for cloning said Pod.

# Initial values, some may be replaced depending on parameters
CURL=`which curl`
CLONE_TYPE="LINKED"
CLONE_ROLE="NORMAL"

function usage {
	echo "Usage: $0 --clonepodid ID --clonepodname NAME --sourcepodid ID --host HOST --cookie COOKIE"
}


while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		--clonepodid)
		CLONE_POD_ID="$2"
		shift
		;;

		--clonepodname)
		CLONE_POD_NAME="$2"
		shift
		;;

		--sourcepodid)
		SOURCE_POD_ID="$2"
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
if [ -z "${CLONE_POD_ID}" ]; then
	usage
	exit 3
fi

if [ -z "${CLONE_POD_NAME}" ]; then
	usage
	exit 3
fi

if [ -z "${SOURCE_POD_ID}" ]; then
	usage
	exit 2
fi

if [ -z "${HOST}" ]; then
	usage
	exit 2
fi

if [ -z "${COOKIE}" ]; then
	usage
	exit 2
fi


output=`"${CURL}" -s "${HOST}/clone_pod.cgi" \
-H "Cookie: netlab_sid=${COOKIE}" \
-H 'Origin: http://netlab.netlab-domain' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.8' \
-H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryGRRZ58cJg9jJf32K' \
-H 'Accept: text/html,application/xhtm.*xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
-H 'Cache-Control: max-age=0' \
-H "Referer: ${HOST}/clone_pod.cgi" \
-H 'Connection: keep-alive' \
--data-binary $'------WebKitFormBoundaryGRRZ58cJg9jJf32K\r\nContent-Disposition: form-data; name="_state"\r\n\r\nconf_name_submit\r\n------WebKitFormBoundaryGRRZ58cJg9jJf32K\r\nContent-Disposition: form-data; name="pod_id"\r\n\r\n'"${SOURCE_POD_ID}"$'\r\n------WebKitFormBoundaryGRRZ58cJg9jJf32K\r\nContent-Disposition: form-data; name="source_pod_id"\r\n\r\n'"${SOURCE_POD_ID}"$'\r\n------WebKitFormBoundaryGRRZ58cJg9jJf32K\r\nContent-Disposition: form-data; name="clone_pod_id"\r\n\r\n'"${CLONE_POD_ID}"$'\r\n------WebKitFormBoundaryGRRZ58cJg9jJf32K\r\nContent-Disposition: form-data; name="clone_pod_name"\r\n\r\n'"${CLONE_POD_NAME}"$'\r\n------WebKitFormBoundaryGRRZ58cJg9jJf32K--\r\n' \
--compressed`


# Determine which version of grep to use based on OS X or Linux!
grep -V | grep "BSD" > /dev/null 2>&1
if [ "$?" == 0 ]; then
	grep="grep -Eo"
else
	grep="grep -Po"
fi

# Find "pl_index"
pl_index=`echo "${output}" | grep "pl_index" | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


# Find "pc_type"
pc_type=`echo "${output}" | grep "pc_type" | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


# Find "vm_id_of_source" (this is source_vm_id)
source_vm_id=`echo "${output}" | grep "vm_id_of_source" | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


# Find "source_snapshot" -A 2, "selected"
source_snapshot=`echo "${output}" | grep "source_snapshot" -A 2 | grep "selected" | ${grep} ">.*?<" | sed 's/>//' | sed 's/<//'`


# Find "clone_name"
clone_name=`echo "${output}" | grep "clone_name" | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


## Find "clone_type" (this is kinda hokey... could just return "LINKED" as default)
clone_type=`echo "${output}" | grep "name=\"clone_type" -A 1 | grep "value" | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


# Find "clone_role"
clone_role=`echo "${output}" | grep "name=\"clone_role" -A 3 | grep "selected" | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


# Find "default_datastore" (this is clone_datastore)
clone_datastore=`echo "${output}" | grep "default_datastore" | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


# Find "clone_storage_alloc"
clone_storage_alloc=`echo "${output}" | grep "clone_storage_alloc" -A 1 | ${grep} "value=\".*?\"" | sed 's/value=//' | sed 's/"//g'`


# Find "clone_host_or_group" (vh_id)
vh_id=`echo "${output}" | grep -E "value=\"H:[0-9]*\"? selected=\"selected\"" | ${grep} "\"H:.*?\"" | sed 's/H://' | sed 's/"//g'`



# Compile all the data into a string to be returned
# If any variable is empty, bail
if [ -z "${pl_index}" -o -z "${pc_type}" -o -z "${source_vm_id}" -o -z "${source_snapshot}" -o -z "${clone_name}" -o -z "${clone_type}" -o -z "${clone_role}" -o -z "${clone_datastore}" -o -z "${clone_storage_alloc}" -o -z "${vh_id}" ]; then
	exit 1
fi

# If they're all set, assume they're all set to the same number of lines, convert to arrays
arr_pl_index=()
while read -r line; do arr_pl_index+=("$line"); done <<< "${pl_index}"
arr_pc_type=()
while read -r line; do arr_pc_type+=("$line"); done <<< "${pc_type}"
arr_source_vm_id=()
while read -r line; do arr_source_vm_id+=("$line"); done <<< "${source_vm_id}"
arr_source_snapshot=()
while read -r line; do arr_source_snapshot+=("$line"); done <<< "${source_snapshot}"
arr_clone_name=()
while read -r line; do arr_clone_name+=("$line"); done <<< "${clone_name}"
arr_clone_type=()
while read -r line; do arr_clone_type+=("$line"); done <<< "${clone_type}"
arr_clone_role=()
while read -r line; do arr_clone_role+=("$line"); done <<< "${clone_role}"
arr_clone_datastore=()
while read -r line; do arr_clone_datastore+=("$line"); done <<< "${clone_datastore}"
arr_clone_storage_alloc=()
while read -r line; do arr_clone_storage_alloc+=("$line"); done <<< "${clone_storage_alloc}"
arr_vh_id=()
while read -r line; do arr_vh_id+=("$line"); done <<< "${vh_id}"

# Loop through the arrays, creating a multi-line string to return, deliminated by $delim
foo=""
delim="|"
for i in "${!arr_pl_index[@]}"; do
	foo+="${arr_pl_index[$i]}${delim}${arr_pc_type[$i]}${delim}${arr_source_vm_id[$i]}${delim}${arr_source_snapshot[$i]}${delim}${arr_clone_name[$i]}${delim}${arr_clone_type[$i]}${delim}${arr_clone_role[$i]}${delim}${arr_clone_datastore[$i]}${delim}${arr_clone_storage_alloc[$i]}${delim}${arr_vh_id[$i]}
"
done

# Remove trailing newline character on the last line of output
while read line; do
	if [ ! -z "${line}" ]; then
		echo "$line"
	fi
done <<< "${foo}"
