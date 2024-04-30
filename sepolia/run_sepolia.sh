#!/bin/bash
docker_image="bee-act-sepolia"
docker_container="sp-bee-sepolia"
bee_config_file="bee-sepolia.yaml"
rpc_url=$(grep 'blockchain-rpc-endpoint:' $bee_config_file | awk '{print $2}')
private_key=$1

if [ -z "$private_key" ]
then
  echo "Error: Private key not provided. Please provide the private key as an argument."
  exit 1
fi
if [ -z "$rpc_url" ]
then
  printf "Error: Could not parse RPC URL from '%s'. Make sure 'blockchain-rpc-endpoint' is set." "$bee_config_file"
  exit 1
fi

printf "Building image %s ...\n" "$docker_image"
docker build -q -t "$docker_image" -f ../sepolia.Dockerfile .

printf "Starting container as %s ...\n" "$docker_container"
docker run -d -p 1633:1633 -p 1634:1634 -p 1635:1635 --name "$docker_container" "$docker_image"

sleep 4
node_wallet=$(docker logs sp-bee-sepolia | grep 'cannot continue until there is at least' | grep -o -E 'address"="0x[a-fA-F0-9]{40}' | uniq | awk -F'="' '{print $2}')

printf "Node wallet: %s\n" "$node_wallet"
print "Make sure that the wallet has some sETH to proceed (at least 0.01)!\n"

# Funding the Bee wallet
cd ../wallet-tool || exit
docker build --progress=plain --no-cache -t wallet-tool . \
--build-arg="RPC_URL=$rpc_url" \
--build-arg="P_KEY=$private_key"

docker run -it -e T0_ADDRESS="$node_wallet" --rm wallet-tool fund-wallet

# Ensuring that the node is running, even if it got stopped during the process
printf "\nDONE: \nThe node is fully funded and runs as container: %s\n" "$(docker start "$docker_container")"