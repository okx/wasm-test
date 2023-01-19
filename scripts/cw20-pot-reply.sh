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
#echo $res | jq
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

res=$(exchaincli tx wasm instantiate "${code_id}" '{"decimals":10,"initial_balances":[{"address":"'$captain'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain" --from captain $TX_EXTRA)
#echo $res | jq
cw20ContractAddr1=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "contract address: $cw20ContractAddr1"


res=$(exchaincli tx wasm store $contract_dir/cw20-pot-reply/artifacts/cw20_pot.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
pot_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

res=$(exchaincli tx wasm instantiate "${pot_code_id}" '{}' --label cw20_pot_reply --admin "$captain" --from captain $TX_EXTRA)
potContractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "pot contract address: $potContractAddr"

res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"send":{"amount":"1","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
event_name=$(echo $res | jq '.logs[0].events[2].type' | sed 's/\"//g')
if [[ $event_name != "reply" ]]; then
  echo "unexpected event name"
  exit 1
fi

res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"send":{"amount":"2","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
raw_log=$(echo $res | jq '.raw_log' | sed 's/\"//g')
if [[ $raw_log != "execute wasm contract failed: Cannot set to own account: submessages: dispatch: submessages: dispatch: failed to execute message; message index: 0" ]]; then
  echo "unexpected raw log"
  exit 1
fi


res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"send":{"amount":"3","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
event_name=$(echo $res | jq '.logs[0].events[2].type' | sed 's/\"//g')
if [[ $event_name != "wasm" ]]; then
  echo "unexpected event name"
  exit 1
fi

res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"send":{"amount":"4","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
event_name=$(echo $res | jq '.logs[0].events[2].type' | sed 's/\"//g')
if [[ $event_name != "reply" ]]; then
  echo "unexpected event name"
  exit 1
fi

res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"send":{"amount":"5","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
event_name=$(echo $res | jq '.logs[0].events[2].type' | sed 's/\"//g')
if [[ $event_name != "reply" ]]; then
  echo "unexpected event name"
  exit 1
fi

res=$(exchaincli tx wasm execute "$cw20ContractAddr1" '{"send":{"amount":"6","contract":"'$potContractAddr'","msg":"e30="}}' --from captain $TX_EXTRA)
event_name=$(echo $res | jq '.logs[0].events[2].type' | sed 's/\"//g')
if [[ $event_name != "reply" ]]; then
  echo "unexpected event name"
  exit 1
fi

allowance=$(exchaincli query wasm contract-state smart "$cw20ContractAddr1" '{"allowance":{"owner":"'$potContractAddr'","spender":"'$captain'"}}' | jq '.data.allowance' | sed 's/\"//g')
if [[ $allowance -ne 9 ]]; then
  echo "invalid allowance: $allowance"
  exit 1
fi

echo "all succeed!"