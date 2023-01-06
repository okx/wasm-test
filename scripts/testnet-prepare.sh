rm -rf ~/.exchaincli

CHAIN_ID=$1
NODE=$2

exchaincli config chain-id $CHAIN_ID
exchaincli config output json
exchaincli config indent true
exchaincli config trust-node true
exchaincli config keyring-backend test
exchaincli config node $NODE