source ./localnet-prepare.sh

TX_EXTRA="--fees 0.01okt --gas 50000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"
temp=$(exchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)
captain=$(exchaincli keys show captain | jq -r '.eth_address')
proposal_deposit="100okt"


# usage:
#   proposal_vote {proposal_id}
proposal_vote() {
  ./vote.sh $1 $CHAIN_ID
}

echo "## update wasm code deployment whitelist"
res=$(exchaincli tx gov submit-proposal update-wasm-deployment-whitelist "all" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
echo $res
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

. ./utils.sh

exchaincli keys add user --recover -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y

contract_dir=$(get_contract_dir erc20)
check_file_exit $contract_dir

useraddr=$(exchaincli keys show user | jq -r '.eth_address')
res=$(exchaincli tx wasm store $contract_dir/artifacts/cw_erc20.wasm --fees 0.01okt --from user --gas=2000000 -b block -y)
echo $res
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr} --fees 0.001okt --from user -b block -y)
contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
exchaincli tx wasm execute "$contractAddr" '{"transfer":{"amount":"100","recipient":"0xCf164e001d86639231d92Ab1D71DB8353E43C295"}}' --fees 0.001okt --from user -b block -y

echo " ========================================================== "
echo "## show all codes uploaded ##"
exchaincli query wasm list-code

echo " ========================================================== "
echo "## show contract info by contract addr ##"
exchaincli query wasm contract "$contractAddr"

echo " ========================================================== "
echo "## show contract update history by contract addr ##"
exchaincli query wasm contract-history "$contractAddr"

echo " ========================================================== "
echo "## query contract state by contract addr ##"
echo "#### all state"
exchaincli query wasm contract-state all "$contractAddr"
echo "#### raw state"
exchaincli query wasm contract-state raw "$contractAddr" 0006636F6E666967636F6E7374616E7473
echo "#### smart state"
exchaincli query wasm contract-state smart "$contractAddr" "{\"balance\":{\"address\":\"${useraddr}\"}}"
exchaincli query wasm contract-state smart "$contractAddr" '{"balance":{"address":"0xCf164e001d86639231d92Ab1D71DB8353E43C295"}}'

echo "all case passed"