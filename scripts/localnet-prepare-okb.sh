rm -rf ~/.okbchaincli

CHAIN_ID="okbchain-67"
NODE="http://localhost:26657"

okbchaincli config chain-id $CHAIN_ID
okbchaincli config output json
okbchaincli config indent true
okbchaincli config trust-node true
okbchaincli config keyring-backend test
okbchaincli config node $NODE
