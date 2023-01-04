rm -rf ~/.exchaincli

CHAIN_ID=$1
NODE=$2

exchaincli config chain-id exchain-65
exchaincli config output json
exchaincli config indent true
exchaincli config trust-node true
exchaincli config keyring-backend test
exchaincli config node https://exchaintesttmrpc.okex.org
exchaincli keys add user --recover -m "rifle purse jacket embody deny win where finish door awful space pencil" -y