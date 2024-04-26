#!/bin/bash
node_wallet=$1
rpc_url=$2
node_wallet_pwd='t3stn3tBee'
bee_container='sp-bee-sepolia'
gas_max=50000

function retrieve_funds() {
  to_address=$(w3 signer get dev_wallet | jq -r '.address')
  amount=$1
  ticker=$2
  printf "\nAddress %s will receive %f %s...\n" "$to_address" "$amount" "$ticker"
  tx_hash=$(w3 send -s node_wallet --force "$to_address" "$amount" "$ticker")
  printf "Tx. hash: %s\n" "$tx_hash"
  printf '%.s-' {1..80}
}

docker cp "$bee_container":/home/bee/.bee/keys/swarm.key node_swarm.key

/usr/bin/expect <<EOF 2>/dev/null
spawn w3 signer add node_wallet --keyfile node_swarm.key
expect "Keyfile password:"
send "$node_wallet_pwd\r"
expect eof
EOF

w3 signer    list

if [[ "$(w3 chain active)" != 'sepolia' ]]; then
  echo "Adding Sepolia chain..."
  w3 chain     add sepolia 11155111 ETH --rpc "$rpc_url"
  w3 config    set default_chain sepolia
fi

w3 token     add bzz 0x543dDb01Ba47acB11de34891cD86B675F04840db
w3 token     list

balance=$(w3 token balance bzz "$node_wallet")
printf "Node wallet BZZ balance: %f\n" "$balance"
if (( $(echo "$balance > 0" | bc -l) )); then
  retrieve_funds "$balance" BZZ
fi

balance=$(w3 balance "$node_wallet" -u wei)
gas_fee=$(w3 block latest | jq -r '.baseFeePerGas')
tx_fee=$(echo "$gas_fee * $gas_max" | bc -l)
retrievable=$(echo "$balance-$tx_fee" | bc -l)
retrievable=$(echo "scale=18; $retrievable/1000000000000000000" | bc -l)

if (( $(echo "$retrievable < 0" | bc -l) )); then
  retrievable=0
fi

printf "Retrievable ETH balance: %f\n" "$retrievable"
if (( $(echo "$retrievable > 0" | bc -l) )); then
  retrieve_funds "$retrievable" ETH
fi