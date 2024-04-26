Wallet Tool
===
This is a tool to be able to programmatically interact with Ethereum wallets on the Sepolia testnet.

Its main purpose is to be able to fund a test Bee node's account with the necessary coins and tokens, to allow setting
up Bee nodes without interacting with a MetaMask or other UI manually.

The tool is using the [web3cli](https://github.com/coccoinomane/web3cli) project, which was written in Python.

## Running in Docker

### Building the image

The Dockerfile can be used to build the image. Two build arguments are required:

- `RPC_URL` - the URL of the Ethereum node to connect to
- `P_KEY` - the private key of the wallet to use as the source of funds

__Note:__ This solution is intended for testnet usage only. To protect the private key, the resulting Docker image
should never be uploaded to any public registry.

```shell
docker build --progress=plain --no-cache -t wallet-tool . 
--build-arg="RPC_URL=https://eth-sepolia.g.alchemy.com/v2/api-key" 
--build-arg="P_KEY=0x123456"
```

### Running the container to fund a wallet

The wallet to fund with the necessary coins and tokens is specified by the `T0_ADDRESS` environment variable. The
container will use this address after starting up to perform the transactions, then it will stop.

```shell
docker run -it -e T0_ADDRESS=0x1234567890123456789012345678901234567890 --rm wallet-tool fund-wallet
```