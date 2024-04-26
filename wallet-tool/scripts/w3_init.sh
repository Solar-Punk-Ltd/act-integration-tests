#!/bin/bash
private_key=$1
rpc_url=$2

w3 signer    add dev_wallet -p "$private_key"
w3 signer    list
w3 config    set default_signer dev_wallet

w3 chain     add sepolia 11155111 ETH --rpc "$rpc_url"
w3 chain     list
w3 config    set default_chain sepolia

w3 token     add  --chain sepolia bzz 0x543dDb01Ba47acB11de34891cD86B675F04840db
w3 token     list --chain sepolia