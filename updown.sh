#!/bin/bash

input_file=$1
host="localhost"
bee_api_port="1633"

cleanup() {
    # before exit, remove the downloaded file
    rm -f _${input_file}
}

# Trap the exit signal and call cleanup function
trap cleanup EXIT

# ----------------
# public key
# ----------------
addresses_response=$(curl -s "http://${host}:${bee_api_port}/addresses" \
    -H "accept: application/json, text/plain, */*")
public_key=$(echo "$addresses_response" | jq -r '.publicKey')

# ----------------
# stamp
# ----------------
stamp_url="http://${host}:${bee_api_port}/stamps/420000000/17"
echo "Buying stamp        POST: ${stamp_url}"
stamp_response=$(curl -s -X POST "${stamp_url}" -H "accept: application/json, text/plain, */*")
stamp_batch_id=$(echo "$stamp_response" | jq -r '.batchID')
echo "                Batch ID: ${stamp_batch_id}"

# ----------------
# upload
# ----------------
upload_url="http://${host}:${bee_api_port}/bzz?name=${input_file}"
echo "Uploading file      POST: ${upload_url}"
upload_response=$(curl -L -i -s -X POST "${upload_url}" \
    -H "accept: application/json, text/plain, */*" \
    -H "swarm-postage-batch-id: ${stamp_batch_id}" \
    -H "swarm-deferred-upload: true" \
    -H "content-type: application/octet-stream" \
    -H "Swarm-Act: true" \
    --data-binary @./${input_file})
history_address=$(echo "$upload_response" | grep -Fi 'Swarm-Act-History-Address' | cut -d ' ' -f2 | tr -d '\r')
response_body=$(echo "$upload_response" | sed -n '/^\r$/,$p')
reference=$(echo "$response_body" | jq -r '.reference')
echo "               Reference: ${reference}"
echo "              Public Key: ${public_key}"
echo "         History Address: ${history_address}"

# ------------------
# download with act
# ------------------
download_url="http://${host}:${bee_api_port}/bzz/${reference}/${input_file}"
echo "Downloading with ACT GET: ${download_url}"
curl -L -s "${download_url}" \
    -H "accept: application/json, text/plain, */*" \
    -H "Swarm-Act: true" \
    -H "Swarm-Act-History-Address: $history_address" \
    -H "Swarm-Act-Publisher: $public_key" \
    -H "Swarm-Act-Timestamp: 1" \
    --output _${input_file}

diff ${input_file} _${input_file} > /dev/null
if [ $? -eq 0 ]; then 
    echo -e "\033[0;32mUploaded and downloaded files are identical\033[0m"
else 
    echo -e "\033[0;31mUploaded and downloaded files are different\033[0m"
    diff ${input_file} _${input_file}
    exit 1
fi

# --------------------
# download without act
# --------------------
echo "Downloading without ACT"
response=$(curl -L -s -w "%{http_code}" "${download_url}" \
    -H "accept: application/json, text/plain, */*" \
    --output _${input_file})
http_status=$(echo "$response" | tail -n1)
if [ $http_status -ne 200 ]; then
    echo -e "\033[0;32mFailed to download the file - this is OK\033[0m"
else 
    echo -e "\033[0;31mFile downloaded successfully - this is an error\033[0m"
    exit 1
fi

# ------------------------------------
# download with act, wrong public key
# ------------------------------------
echo "Downloading with ACT, wrong public key"
response=$(curl -L -s -w "%{http_code}" "${download_url}" \
    -H "accept: application/json, text/plain, */*" \
    -H "Swarm-Act: true" \
    -H "Swarm-Act-History-Address: $history_address" \
    -H "Swarm-Act-Publisher: 02d28938c3d617ba84f431e4dbb24c767c05d622cf8bbd61bbfaa429c763324723" \
    -H "Swarm-Act-Timestamp: 1" \
    --output _${input_file})
http_status=$(echo "$response" | tail -n1)
if [ $http_status -ne 200 ]; then
    echo -e "\033[0;32mFailed to download the file - this is OK\033[0m"
else 
    echo -e "\033[0;31mFile downloaded successfully - this is an error\033[0m"
    exit 1
fi
