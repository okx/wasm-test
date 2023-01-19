CHAIN_ID="exchain-67"
NODE="http://localhost:26657"
#NODE="http://18.166.181.170:46657"

QUERY_EXTRA="--node=$NODE"
TX_EXTRA="--fees 0.01okt --gas 50000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"
captain=$(exchaincli keys show captain -a)
admin18=$(exchaincli keys show admin18 -a)
admin17=$(exchaincli keys show admin17 -a)

. ./utils.sh
contract_dir=${PWD}/../contract
check_file_exit $contract_dir

res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
echo "code_id: $code_id"

res=$(exchaincli tx wasm instantiate "${code_id}" '{"decimals":10,"initial_balances":[{"address":"'$captain'","amount":"100"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain" --from captain $TX_EXTRA)
cw20contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "contract address: $cw20contractAddr"

res=$(exchaincli tx wasm execute "$cw20contractAddr" '{"transfer":{"amount":"10","recipient":"'$admin18'"}}' --from captain $TX_EXTRA)
balance=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"balance":{"address":"'$captain'"}}' "$QUERY_EXTRA" | jq '.data.balance' | sed 's/\"//g')
if [[ $balance -ne 90 ]];
then
  echo "unexpected balance after transfer"
  exit 1
fi;

res=$(exchaincli tx wasm migrate "$cw20contractAddr" "$code_id" "{}" --from captain $TX_EXTRA)
action_name=$(echo $res | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
if [[ $action_name != "migrate" ]]; then
  echo "unexpected action name"
  exit 1
fi

res=$(exchaincli tx wasm execute "$cw20contractAddr" '{"transfer":{"amount":"10","recipient":"'$admin18'"}}' --from captain $TX_EXTRA)
balance=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"balance":{"address":"'$captain'"}}' "$QUERY_EXTRA" | jq '.data.balance' | sed 's/\"//g')
if [[ $balance -ne 80 ]];
then
  echo "unexpected balance after transfer"
  exit 1
fi;

admin=$(exchaincli query wasm contract $cw20contractAddr $QUERY_EXTRA | jq '.contract_info.admin' | sed 's/\"//g')
if [[ $admin != $captain ]]; then
  echo "unexpected admin: $admin"
  exit 1
fi

res=$(exchaincli tx gov submit-proposal migrate-contract "$cw20contractAddr" "$code_id" "{}" --deposit=100okt --title "migration" --description "migrate cw20_base" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
res=$(exchaincli tx gov vote "$proposal_id" yes --from captain $TX_EXTRA)
admin=$(exchaincli query wasm contract $cw20contractAddr $QUERY_EXTRA | jq '.contract_info.admin' | sed 's/\"//g')
if [[ $admin != "" ]]; then
  echo "unexpected admin: $admin"
  exit 1
fi

res=$(exchaincli tx wasm instantiate "${code_id}" '{"decimals":10,"initial_balances":[{"address":"'$captain'","amount":"100"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain" --from captain $TX_EXTRA)
cw20contractAddr2=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "contract address2: $cw20contractAddr2"

admin=$(exchaincli query wasm contract $cw20contractAddr2 $QUERY_EXTRA | jq '.contract_info.admin' | sed 's/\"//g')
if [[ $admin != $captain ]]; then
  echo "unexpected admin: $admin"
  exit 1
fi


res=$(exchaincli tx gov submit-proposal update-wasm-contract-method-blocked-list "$cw20contractAddr2" "transfer" --deposit 100okt --title "blacklist" --description "block transfer method of cw20_base contract" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
res=$(exchaincli tx gov vote "$proposal_id" yes --from captain $TX_EXTRA)
admin=$(exchaincli query wasm contract $cw20contractAddr $QUERY_EXTRA | jq '.contract_info.admin' | sed 's/\"//g')
if [[ $admin != "" ]]; then
  echo "unexpected admin: $admin"
  exit 1
fi

echo "succeed~"
