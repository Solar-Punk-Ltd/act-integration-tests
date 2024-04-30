#!/bin/bash
to_address=$1
tx_confirm_poll_sec=5
tx_confirm_timeout_sec=30

function send() {
  amount=$1
  ticker=$2
  printf "\nAddress %s will receive %f %s...\n" "$to_address" "$amount" "$ticker"
  tx_hash=$(w3 send --force "$to_address" "$amount" "$ticker")
  printf "Tx. hash: %s\n" "$tx_hash"
  printf '%.s-' {1..80}
  # confirming transaction before returning
  confirm_tx "$tx_hash"
}

function confirm_tx() {
  tx_hash=$1
  start_time=$(date +%s) # time in seconds since 1970-01-01 00:00:00 UTC

  while true; do
    status=$(w3 tx rc "$tx_hash" | jq -r '.status')

    if [ "$status" == "1" ]; then
      break
    fi

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    printf "Elapsed time: %d seconds\n" "$elapsed_time"
    # timeout after the set time
    if [ $elapsed_time -ge $tx_confirm_timeout_sec ]; then
      echo "Error: Transaction confirmation timed out."
      break
    fi

    sleep $tx_confirm_poll_sec
  done
}

# Usage:
# send <amount> <ticker>
send 0.01 ETH
send 1.0 BZZ