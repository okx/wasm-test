
source ./localnet-prepare-okb.sh
. ./utils.sh

TX_EXTRA="--fees 0.01okb --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"

temp=$(okbchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)
captain=$(okbchaincli keys show captain | jq -r '.eth_address')
proposal_deposit="100okb"


# usage:
#   proposal_vote {proposal_id}
proposal_vote() {
  ./vote_okb.sh $1 $CHAIN_ID
}

function check_address_decode_failed() {
    if [[ $1 != *"execute wasm contract failed: Generic error: addr_validate errored: decoding bech32 failed: invalid bech32 string length 5: failed to execute message; message index: 0"* ]]; then
        echo "unexcepted output" $1
        exit 1
      fi
}

echo "## update wasm code deployment whitelist"
res=$(okbchaincli tx gov submit-proposal update-wasm-deployment-whitelist "all" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
echo $res
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"


res=$(okbchaincli tx wasm store ../contract/cwokt/artifacts/cwokt-aarch64.wasm --fees 0.01okb --from captain --gas=auto  -b block -y)
code_id=$(echo "$res" | jq -r '.logs[0].events[1].attributes[0].value')
echo "code_id: $code_id"
res=$(okbchaincli tx wasm instantiate $code_id '{}' --label cwokt --admin 0xbbE4733d85bc2b90682147779DA49caB38C0aA1F --from captain --fees 0.01okb --gas 3000000 -y -b block)
contractAddr=$(echo "$res" | jq -r '.logs[0].events[0].attributes[0].value')
echo "contractAddr: $contractAddr"
okbchaincli tx wasm execute 0x5A8D648DEE57b2fc90D98DC17fa887159b69638b '{"transfer":{"recipient":"0x2Bd4AF0C1D0c2930fEE852D07bB9dE87D8C07044"}}' --from captain --amount 1okb --fees 0.01okb --gas 30000000 -y -b block
