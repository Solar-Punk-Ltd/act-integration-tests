#!/bin/bash

function checkenv {
  local var_value
  var_value=$(printenv "$1")

  if [ -z "$var_value" ]
  then
    echo "$1 is not set or is empty"
    exit 1
  else
    echo "$1 is set to '$var_value'"
  fi
}

function execute {
  local hurl_file=$1
  hurl "$hurl_file" -v --report-html report --variable file_name=test_content.md
}

public_key=$(swarm-cli addresses | grep -x "Public Key: .*" | awk -F': ' '{print $2}' | sed 's/^[[:space:]]*//')
stamp=$(swarm-cli stamp list | grep -x "Stamp ID: .*" | awk -F': ' '{print $2}' | sed 's/^[[:space:]]*//')

export HURL_public_key="$public_key"
export HURL_batch_id="$stamp"
export HURL_host=localhost
export HURL_bee_api_port=1633

checkenv "HURL_public_key"
checkenv "HURL_batch_id"
checkenv "HURL_host"
checkenv "HURL_bee_api_port"

execute ./tests/01.hurl
execute ./tests/01_a.hurl
execute ./tests/02.hurl
execute ./tests/02_a.hurl
execute ./tests/03.hurl
execute ./tests/04.hurl
execute ./tests/04_a.hurl