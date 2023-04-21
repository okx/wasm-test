source ./localnet-prepare-okb.sh

TX_EXTRA="--fees 0.01okb --gas 30000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"
temp=$(okbchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)
captain=$(okbchaincli keys show captain | jq -r '.eth_address')
proposal_deposit="100okb"


# usage:
#   proposal_vote {proposal_id}
proposal_vote() {
  ./vote_okb.sh $1 $CHAIN_ID
}

echo "## update wasm code deployment whitelist"
res=$(okbchaincli tx gov submit-proposal update-wasm-deployment-whitelist "all" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
echo $res
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

. ./utils.sh

okbchaincli keys add user --recover -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y

contract_dir=$(get_contract_dir escrow)
check_file_exit $contract_dir

useraddr=$(okbchaincli keys show user | jq -r '.eth_address')

res=$(okbchaincli tx wasm store ${contract_dir}/artifacts/cw_escrow-aarch64.wasm --fees 0.01okb --from user --gas=2000000 -b block -y)
echo "store code..."
echo $res
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(okbchaincli tx wasm instantiate "$code_id" "{\"arbiter\":\"${useraddr}\",\"end_height\":100000,\"recipient\":\"0x2Bd4AF0C1D0c2930fEE852D07bB9dE87D8C07044\"}" --label test1 --admin $useraddr --fees 0.001okb --from user -b block -y)
contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "instantiate contract..."
echo $res
#okbchaincli tx send ex1h0j8x0v9hs4eq6ppgamemfyu4vuvp2sl0q9p3v $contractAddr 999okb --fees 0.01okb -y -b block
okbchaincli tx wasm execute "$contractAddr" '{"approve":{"quantity":[{"amount":"1","denom":"okb"}]}}' --amount 888okb --fees 0.001okb --from user -b block -y

echo "test case success"
