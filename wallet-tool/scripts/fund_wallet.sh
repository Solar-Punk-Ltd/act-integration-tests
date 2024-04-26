#!/bin/bash
to_address=$1

function send() {
  amount=$1
  ticker=$2
  printf "\nAddress %s will receive %f %s...\n" "$to_address" "$amount" "$ticker"
  tx_hash=$(w3 send --force "$to_address" "$amount" "$ticker")
  printf "Tx. hash: %s\n" "$tx_hash"
  printf '%.s-' {1..80}
}

# Usage:
# send <amount> <ticker>
send 0.001 ETH
sleep 8
send 1.0 BZZ