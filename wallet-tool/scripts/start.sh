#!/bin/bash
address=$1
printf "Funding wallet %s\n" "$address"
printf '%.s=' {1..80}

./fund_wallet.sh "$address"