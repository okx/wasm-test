rm -rf ~/.exchaincli

export CHAIN_ID="exchain-65"
export NODE="https://exchaintesttmrpc.okex.org"

exchaincli config chain-id $CHAIN_ID
exchaincli config output json
exchaincli config indent true
exchaincli config trust-node true
exchaincli config keyring-backend test
exchaincli config node $NODE