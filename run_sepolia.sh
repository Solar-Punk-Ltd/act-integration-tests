docker_image="bee-act-sepolia"
docker_container="sp-bee-sepolia"
rpc_url="https://eth-sepolia.g.alchemy.com/v2/api-key"
private_key=""

printf "Building image %s ...\n" "$docker_image"
docker build -q -t "$docker_image" -f Dockerfile_sepolia .

printf "Starting container as %s ...\n" "$docker_container"
docker run -d -p 1633:1633 -p 1634:1634 -p 1635:1635 --name "$docker_container" "$docker_image"

sleep 4
node_wallet=$(docker logs sp-bee-sepolia | grep 'cannot continue until there is at least' | grep -o -E 'address"="0x[a-fA-F0-9]{40}' | uniq | awk -F'="' '{print $2}')

printf "Node wallet: %s\n" "$node_wallet"
print "Make sure that the wallet has some sETH to proceed (at least 0.001)!\n"

cd ./wallet-tool || exit
docker build --progress=plain --no-cache -t wallet-tool . \
--build-arg="RPC_URL=$rpc_url" \
--build-arg="P_KEY=$private_key"

docker run -it -e T0_ADDRESS="$node_wallet" --rm wallet-tool fund-wallet