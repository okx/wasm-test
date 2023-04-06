rm -rf ~/.exchaincli

CHAIN_ID="exchain-67"
NODE="http://localhost:26657"

exchaincli config chain-id $CHAIN_ID
exchaincli config output json
exchaincli config indent true
exchaincli config trust-node true
exchaincli config keyring-backend test
exchaincli config node $NODE