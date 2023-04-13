source ./localnet-prepare.sh

TX_EXTRA="--fees 0.01okt --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"
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
contract_dir=${PWD}/../contract
check_file_exit $contract_dir

res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
echo $res | jq
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

res=$(exchaincli tx wasm instantiate "${code_id}" '{"decimals":10,"initial_balances":[{"address":"'$captain'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain" --from captain $TX_EXTRA)
echo $res | jq
cw20ContractAddr1=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "contract address: $cw20ContractAddr1"

#res=$(exchaincli tx wasm execute "$contractAddr" '{"increase_allowance":{"amount":"10","spender":"ex190227rqaps5nplhg2tg8hww7slvvquzy0qa0l0"}}' --from captain $TX_EXTRA)
#echo $res | jq

res=$(exchaincli tx wasm instantiate "${code_id}" '{"decimals":10,"initial_balances":[{"address":"'$captain'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain" --from captain $TX_EXTRA)
echo $res | jq
cw20ContractAddr2=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "contract address: $cw20ContractAddr2"

res=$(exchaincli tx wasm store $contract_dir/cw20-pot/artifacts/cw20_pot.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
echo $res | jq
pot_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

res=$(exchaincli tx wasm instantiate "${pot_code_id}" '{}' --label test1 --admin "$captain" --from captain $TX_EXTRA)
echo $res | jq
potContractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "pot contract address: $potContractAddr"

res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"send":{"amount":"100","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
echo $res | jq

res=$(exchaincli query wasm contract-state smart "$potContractAddr" '{"tokens":{}}')
echo $res | jq

res=$(exchaincli tx wasm execute "$cw20ContractAddr2" '{"send":{"amount":"100","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
echo $res | jq

res=$(exchaincli query wasm contract-state smart "$potContractAddr" '{"tokens":{}}')
echo $res | jq

res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"transfer_from":{"amount":"100","owner":"'$potContractAddr'","recipient":"'$captain'"}}' --from captain $TX_EXTRA)
echo $res | jq

res=$(exchaincli tx wasm execute "$cw20ContractAddr2" '{"transfer_from":{"amount":"100","owner":"'$potContractAddr'","recipient":"'$captain'"}}' --from captain $TX_EXTRA)
echo $res | jq

total_tokens=$(exchaincli query wasm contract-state smart "$potContractAddr" '{"tokens":{}}' | jq '.data.tokens|length')
if [[ $total_tokens -ne 2 ]];
then
  echo "expected total_tokens: $total_tokens"
  exit 1
fi;

echo "all succeed!"