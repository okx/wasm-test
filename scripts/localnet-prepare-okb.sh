rm -rf ~/.okbchaincli

CHAIN_ID="okbchain-67"
NODE="http://localhost:26657"

okbchaincli config chain-id $CHAIN_ID
okbchaincli config output json
okbchaincli config indent true
okbchaincli config trust-node true
okbchaincli config keyring-backend test
okbchaincli config node $NODE


# 4v1r
okbchaincli keys add --recover val0 -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" --coin-type 996 -y
okbchaincli keys add --recover val1 -m "palace cube bitter light woman side pave cereal donor bronze twice work" --coin-type 996 -y
okbchaincli keys add --recover val2 -m "antique onion adult slot sad dizzy sure among cement demise submit scare" --coin-type 996 -y
okbchaincli keys add --recover val3 -m "lazy cause kite fence gravity regret visa fuel tone clerk motor rent" --coin-type 996 -y
