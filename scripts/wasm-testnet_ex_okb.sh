#!/bin/bash
set -o errexit -o nounset -o pipefail


source ./localnet-prepare-okb.sh

. ./utils.sh
contract_dir=${PWD}/../contract
check_file_exit $contract_dir

QUERY_EXTRA="--node=$NODE"
TX_EXTRA_UNBLOCKED="--fees 0.01okb --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b async -y"
TX_EXTRA="--fees 0.01okb --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"

okbchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y
okbchaincli keys add --recover admin17 -m "antique onion adult slot sad dizzy sure among cement demise submit scare" -y
okbchaincli keys add --recover admin18 -m "lazy cause kite fence gravity regret visa fuel tone clerk motor rent" -y
captain_ex=$(okbchaincli keys show captain | jq -r '.address')
captain_0x=$(okbchaincli keys show captain | jq -r '.eth_address')
admin18_ex=$(okbchaincli keys show admin18 | jq -r '.address')
admin17_ex=$(okbchaincli keys show admin17 | jq -r '.address')
proposal_deposit="100okb"

# usage:
#   proposal_vote {proposal_id}
proposal_vote() {
  ./vote_okb.sh $1 $CHAIN_ID $NODE
}

function check_address_is_not_normalized {
  if [[ $1 != *"instantiate wasm contract failed: Generic error: addr_validate errored: Address is not normalized: failed to execute message; message index: 0"* ]]; then
    echo "unexcepted output" $1
    exit 1
  fi
}
function check_query_address_is_not_normalized {
  if [[ $1 != *"invalid request: query wasm contract failed: Generic error: addr_validate errored: Address is not normalized"* ]]; then
    echo "unexcepted output" $1
    exit 1
  fi
}




function check_vm_err() {
      if [[ $1 != *"execute wasm contract failed: Error calling the VM: Error resolving Wasm function: Could not get export: Missing export execute: failed to execute message; message index: 0"* ]]; then
        echo "unexcepted output" $1
        exit 1
      fi
}

#####################################################
########    update deployment whitelist     #########
#####################################################
echo "## update wasm code deployment whitelist"
res=$(okbchaincli tx gov submit-proposal update-wasm-deployment-whitelist "$captain_ex,$admin18_ex" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

#####################################################
#############       store code       ################
#####################################################

echo "## store cw20 contract...everybody"
res=$(okbchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
echo "store cw20 contract succeed"
cw20_code_id1=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

echo "## store cw20 contract...nobody"
res=$(okbchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
echo "store cw20 contract succeed"
cw20_code_id2=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

echo "## store cw20 contract...only-address"
res=$(okbchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-only-address="${captain_ex}" --from captain $TX_EXTRA)
echo "store cw20 contract succeed"
cw20_code_id3=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

echo "## store cw20 contract...null access"
res=$(okbchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --from captain $TX_EXTRA)
echo "store cw20 contract succeed"
cw20_code_id4=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

echo "## store gzipped cw20 contract...null access"
res=$(okbchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm.gz --from captain $TX_EXTRA)
echo "store cw20 contract succeed"
cw20_code_id5=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
data_hash4=$(okbchaincli query wasm code-info "${cw20_code_id4}" $QUERY_EXTRA | jq '.data_hash' | sed 's/\"//g')
data_hash5=$(okbchaincli query wasm code-info "${cw20_code_id5}" $QUERY_EXTRA | jq '.data_hash' | sed 's/\"//g')
if [[ "${data_hash4}" != "${data_hash5}" ]];
then
  echo "wrong data hash of gzipped cw20 contract"
  exit 1
fi;

echo "## store invalid cw20 contract...null access"
res=$(okbchaincli tx wasm store $contract_dir/test/invalid.wasm --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="create wasm contract failed: Error calling the VM: Error during static Wasm validation: Wasm bytecode could not be deserialized. Deserialization error: \I/O Error: UnexpectedEof\: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when store invalid wasm code"
  exit 1
fi;

#####################################################
#########    instantiate contract      ##############
#####################################################
echo "## instantiate everybody..."
res=$(okbchaincli tx wasm instantiate "$cw20_code_id1" '{"decimals":10,"initial_balances":[{"address":"'$captain_ex'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

res=$(okbchaincli tx wasm instantiate "$cw20_code_id1" '{"decimals":10,"initial_balances":[{"address":"'$captain_ex'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from admin18 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"



echo "## instantiate only address..."
res=$(okbchaincli tx wasm instantiate "$cw20_code_id3" '{"decimals":10,"initial_balances":[{"address":"'$captain_ex'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

res=$(okbchaincli tx wasm instantiate "$cw20_code_id3" '{"decimals":10,"initial_balances":[{"address":"'$captain_ex'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from admin18 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="unauthorized: can not instantiate: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  exit 1
fi;

echo "## instantiate nonexistent contract..."
res=$(okbchaincli tx wasm instantiate 9999 '{"decimals":10,"initial_balances":[{"address":"","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="not found: code: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo $res | jq
  echo "expect fail when instantiate nonexistent contract"
  exit 1
fi;

echo "## instantiate cw20 contract with invalid input..."
res=$(okbchaincli tx wasm instantiate "$cw20_code_id5" '{"decimals":10,"initial_balances":[{"address":"","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="instantiate wasm contract failed: Generic error: addr_validate errored: Input is empty: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when instantiate contract with invalid parameters"
  exit 1
fi;

echo "## instantiate cw20 contract with invalid amount..."
res=$(okbchaincli tx wasm instantiate "$cw20_code_id5" '{"decimals":10,"initial_balances":[{"address":"'$captain_ex'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --amount=1000000000000okb --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log_prefix="insufficient funds"
if [[ "${raw_log:0:18}" != "${failed_log_prefix}" ]];
then
  echo "expect fail when instantiate contract with invalid amount"
  exit 1
fi;

echo "## instantiate cw20 contract..."
res=$(okbchaincli tx wasm instantiate "$cw20_code_id5" '{"decimals":10,"initial_balances":[{"address":"'$captain_ex'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "## instantiate cw20 contract with deposit..."
totalAmount="100000000"
depositAmount="20"
depositDenom="okb"
res=$(okbchaincli tx wasm instantiate "$cw20_code_id5" '{"decimals":10,"initial_balances":[{"address":"'$captain_0x'","amount":"'${totalAmount}'"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --amount=${depositAmount}${depositDenom} --from captain $TX_EXTRA)
echo "instantiate cw20 succeed"
if [[ $(echo "$res" | jq '.logs[0].events[0].attributes[0].key' | sed 's/\"//g') != "_contract_address" ]];
then
  echo "unexpected result of instantiate with deposit"
  exit 1
fi;
instantiate_gas_used=$(echo "$res" | jq '.gas_used' | sed 's/\"//g')
cw20contractAddr_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
cw20contractAddr_ex=$(okbchaincli addr convert $cw20contractAddr_0x |  sed -n '2p' | grep -o 'ex1.*')
echo "cw20 contract address: $cw20contractAddr_ex"
echo "cw20 contract address: $cw20contractAddr_ex"
res=$(okbchaincli query account "$cw20contractAddr_0x" $QUERY_EXTRA)
balanceAmount=$(echo "$res" | jq '.value.coins[0].amount' | sed 's/\"//g')
balanceAmount=${balanceAmount%.*}
if [[ ${balanceAmount} != ${depositAmount} ]];
then
  echo "invalid balance amount"
  exit 1
fi;
balanceDenom=$(echo "$res" | jq '.value.coins[0].denom' | sed 's/\"//g')
if [[ ${balanceDenom} != ${depositDenom} ]];
then
  echo "invalid balance denom"
  exit 1
fi;


cw20_balance=$(okbchaincli query wasm contract-state smart "$cw20contractAddr_0x" '{"balance":{"address":"'$captain_0x'"}}' $QUERY_EXTRA | jq '.data.balance' | sed 's/\"//g')
if [[ ${cw20_balance} != ${totalAmount} ]];
then
  echo "invalid cw20 balance"
fi;
#####################################################
#############    execute contract     ###############
#####################################################

transferAmount="100"
echo "## cw20 transfer to invalid recipient..."
res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"'$transferAmount'","recipient":""}}' --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="execute wasm contract failed: Generic error: addr_validate errored: Input is empty: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when cw20 transfer to invalid recipient"
  exit 1
fi;

echo "## cw20 transfer..."
res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --from captain $TX_EXTRA)
standard_gas_used=$(echo "$res" | jq '.gas_used' | sed 's/\"//g')
echo "standard_gas_used:$standard_gas_used"

echo "## cw20 transfer with okb transfer..."
res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --amount=${depositAmount}${depositDenom} --from captain $TX_EXTRA)
gas_used2=$(echo "$res" | jq '.gas_used' | sed 's/\"//g')
echo "gas_used2:$gas_used2"
if [[ "$standard_gas_used" -ge "$gas_used2" ]];
then
  echo "unexpected execute gas used2"
  exit 1
fi;

echo "## pin cw20 code..."
res=$(okbchaincli tx gov submit-proposal pin-codes "$cw20_code_id5" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
proposal_vote "$proposal_id"

total_pinned=$(okbchaincli query wasm pinned $QUERY_EXTRA | jq '.code_ids|length')
if [[ $total_pinned -ne 1 ]];
then
  echo "unexpected total pinned: $total_pinned"
  exit 1
fi;

res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --from captain $TX_EXTRA)
gas_used3=$(echo "$res" | jq '.gas_used' | sed 's/\"//g')
echo "gas_used3:$gas_used3"
if [[ "$standard_gas_used" -le "$gas_used3" ]];
then
  echo "unexpected execute gas used3"
  exit 1
fi;

res=$(okbchaincli tx wasm instantiate "$cw20_code_id5" '{"decimals":10,"initial_balances":[{"address":"'$captain_ex'","amount":"'${totalAmount}'"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --amount=${depositAmount}${depositDenom} --from captain $TX_EXTRA)
instantiate_gas_used2=$(echo "$res" | jq '.gas_used' | sed 's/\"//g')
if [[ "$instantiate_gas_used" -le "$instantiate_gas_used2" ]];
then
  echo "unexpected instantiate gas_used2"
  exit 1
fi;

res=$(okbchaincli tx wasm store $contract_dir/cw4-stake/artifacts/cw4_stake.wasm --from admin18 $TX_EXTRA)
echo "store cw4-stake succeed"
cw4_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(okbchaincli tx wasm instantiate "$cw4_code_id" '{"denom":{"cw20":"'$cw20contractAddr_0x'"},"min_bond":"100","tokens_per_weight":"10","unbonding_period":{"height":100}}' --label test1 --admin "$captain_ex" --from captain $TX_EXTRA)
echo "instantiate cw4-stake succeed-1"
cw4contractAddr_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
cw4contractAddr_ex=$(okbchaincli addr convert $cw4contractAddr_0x |  sed -n '2p' | grep -o 'ex1.*')
echo "cw4-stake contractAddr: $cw4contractAddr_ex" $cw4contractAddr_0x
addr=$(okbchaincli query wasm contract-state smart "$cw4contractAddr_0x" '{"staked":{"address":"'$captain_0x'"}}' $QUERY_EXTRA | jq '.data.denom.cw20' | sed 's/\"//g')
if [[ $addr != $cw20contractAddr_0x ]];
then
  echo "unexpected addr"
  exit 1
fi;

sendAmount="100"
res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"send":{"amount":"'$sendAmount'","contract":"'$cw4contractAddr_0x'","msg":"eyJib25kIjp7fX0="}}' --from captain $TX_EXTRA)
cw4balance=$(okbchaincli query wasm contract-state smart "$cw20contractAddr_0x" '{"balance":{"address":"'$cw4contractAddr_0x'"}}' $QUERY_EXTRA | jq '.data.balance' | sed 's/\"//g')
if [[ $cw4balance -ne $sendAmount ]];
then
  echo "unexpected cw4 contract balance"
  exit 1
fi;

cw4stake=$(okbchaincli query wasm contract-state smart "$cw4contractAddr_0x" '{"staked":{"address":"'$captain_0x'"}}' $QUERY_EXTRA | jq '.data.stake' | sed 's/\"//g')
if [[ $cw4stake -ne $sendAmount ]];
then
  echo "unexpected cw4 contract stake"
  exit 1
fi;

echo "## unpin cw20 code..."
res=$(okbchaincli tx gov submit-proposal unpin-codes "$cw20_code_id5" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
proposal_vote "$proposal_id"
sleep 1
total_pinned=$(okbchaincli query wasm pinned $QUERY_EXTRA | jq '.code_ids|length')
if [[ $total_pinned -ne 0 ]];
then
  exit 1
fi;

res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --from captain $TX_EXTRA)
gas_used4=$(echo "$res" | jq '.gas_used' | sed 's/\"//g')
echo "gas_used4:$gas_used4"
if [[ "$gas_used3" -ge "$gas_used4" ]];
then
  echo "unexpected execute gas used4"
  exit 1
fi;

#####################################################
#############    update&clear admin   ###############
#####################################################
echo "## update admin..."
res=$(okbchaincli tx wasm set-contract-admin "$cw4contractAddr_ex" "$admin18_ex" --from admin17 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="unauthorized: can not modify contract: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when update admin by other address"
  exit 1
fi;

res=$(okbchaincli tx wasm set-contract-admin "$cw4contractAddr_ex" "$admin17_ex" --from captain $TX_EXTRA)
actionName=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
if [[ "${actionName}" != "update-contract-admin" ]];
then
  echo "invalid action name"
  exit 1
fi;

res=$(okbchaincli tx wasm set-contract-admin "$cw4contractAddr_ex" "$admin18_ex" --from admin17 $TX_EXTRA)
actionName=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
if [[ "${actionName}" != "update-contract-admin" ]];
then
  echo "invalid action name"
  exit 1
fi;

echo "## clear admin..."
res=$(okbchaincli tx wasm set-contract-admin "$cw4contractAddr_ex" "0x0000000000000000000000000000000000000000" --from admin18 $TX_EXTRA)
actionName=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
if [[ "${actionName}" != "update-contract-admin" ]];
then
  echo "invalid action name: ${actionName}"
  exit 1
fi;

res=$(okbchaincli tx wasm set-contract-admin "$cw4contractAddr_ex" "$admin17_ex" --from admin18 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="unauthorized: can not modify contract: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when update admin after clear admin"
  exit 1
fi;

#####################################################
#############    migrate contract     ###############
#####################################################
res=$(okbchaincli tx wasm store $contract_dir/test/burner.wasm --from admin18 $TX_EXTRA)
echo "store burner succeed"
burner_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

res=$(okbchaincli tx wasm migrate "$cw20contractAddr_ex" "$burner_code_id" "{}" --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="migrate wasm contract failed: Error parsing into type burner::msg::MigrateMsg: missing field \`payout\`: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when migrating with invalid parameters"
  exit 1
fi;

res=$(okbchaincli tx wasm migrate "$cw20contractAddr_ex" "$burner_code_id" '{"payout": "'$captain_ex'"}' --from admin18 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="unauthorized: can not migrate: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when migrating with address which is not admin"
  exit 1
fi;

res=$(okbchaincli tx wasm migrate "$cw20contractAddr_ex" "$burner_code_id" '{"payout": "'$captain_ex'"}' --from captain $TX_EXTRA)
new_code_id=$(okbchaincli query wasm contract "$cw20contractAddr_ex" $QUERY_EXTRA | jq '.contract_info.code_id' | sed 's/\"//g')
if [[ $new_code_id -ne $burner_code_id ]];
then
  echo "migrate failed"
  exit 1
fi;

operation_name=$(okbchaincli query wasm contract-history "$cw20contractAddr_ex" $QUERY_EXTRA | jq '.entries[1].operation' | sed 's/\"//g')
if [[ $operation_name != "CONTRACT_CODE_HISTORY_OPERATION_TYPE_MIGRATE" ]];
then
  echo "migrate failed"
  exit 1
fi;

res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="execute wasm contract failed: Error calling the VM: Error resolving Wasm function: Could not get export: Missing export execute: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when execute after migrating contract"
  exit 1
fi;

res=$(okbchaincli tx wasm migrate "$cw20contractAddr_ex" "$burner_code_id" '{"payout": "'$captain_ex'"}' --from captain $TX_EXTRA)
new_code_id=$(okbchaincli query wasm contract "$cw20contractAddr_ex" $QUERY_EXTRA | jq '.contract_info.code_id' | sed 's/\"//g')
if [[ $new_code_id -ne $burner_code_id ]];
then
  echo "migrate failed"
  exit 1
fi;

res=$(okbchaincli tx wasm set-contract-admin "$cw20contractAddr_ex" "0x0000000000000000000000000000000000000000" --from captain $TX_EXTRA)
res=$(okbchaincli tx wasm migrate "$cw20contractAddr_ex" "$burner_code_id" '{"payout": "'$captain_ex'"}' --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="unauthorized: can not migrate: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when migrating after clearing admin"
  exit 1
fi;

history_operation_count=$(okbchaincli query wasm contract-history "$cw20contractAddr_ex" $QUERY_EXTRA | jq '.entries|length')
res=$(okbchaincli tx gov submit-proposal migrate-contract "$cw20contractAddr_ex" "$burner_code_id" '{"payout": "'$admin18_ex'"}' --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

if [[ $(okbchaincli query wasm contract-history "$cw20contractAddr_ex" $QUERY_EXTRA | jq '.entries|length') != $(($history_operation_count+1)) ]];
then
  echo "migration by gov failed, $history_operation_count"
  exit 1
fi;
echo "migrate by gov succeed"

#####################################################
##########    blacklist and whitelist     ###########
#####################################################
totalAmount="100000000"
transferAmount="100"

echo "## store cw20 contract..."
res=$(okbchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --from captain $TX_EXTRA)
event_type=$(echo $res | jq '.logs[0].events[1].type' | sed 's/\"//g')
if [[ $event_type != "store_code" ]];
then
  echo "store cw20 contract failed"
  exit 1
fi;
echo "store cw20 contract succeed"
cw20_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
echo "## instantiate cw20 contract..."
res=$(okbchaincli tx wasm instantiate "$cw20_code_id" '{"decimals":10,"initial_balances":[{"address":"'"$captain_ex"'","amount":"'$totalAmount'"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain_ex" --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "## store cw4-stake contract..."
res=$(okbchaincli tx wasm store $contract_dir/cw4-stake/artifacts/cw4_stake.wasm --from admin18 $TX_EXTRA)
event_type=$(echo $res | jq '.logs[0].events[1].type' | sed 's/\"//g')
if [[ $event_type != "store_code" ]];
then
  echo "store cw4-stake contract failed"
  exit 1
fi;
echo "store cw4-stake succeed"
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
echo "## instantiate cw4-stake contract..."
res=$(okbchaincli tx wasm instantiate "$code_id" '{"denom":{"cw20":"'$cw20contractAddr_ex'"},"min_bond":"100","tokens_per_weight":"10","unbonding_period":{"height":100}}' --label test1 --admin $captain_ex --from captain $TX_EXTRA)
event_type=$(echo $res | jq '.logs[0].events[0].type' | sed 's/\"//g')
if [[ $event_type != "instantiate" ]];
then
  echo "instantiate cw4-stake contract failed"
  exit 1
fi;
echo "instantiate cw4-stake succeed-2"
contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "cw4-stake contract address: $contractAddr"

echo "## send cw20 to cw4-stake and call Receive() method of cw4-stake"
res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"send":{"amount":"'$transferAmount'","contract":"'$contractAddr'","msg":"eyJib25kIjp7fX0="}}' --from captain $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
raw_log=$(echo "$res" | jq '.raw_log')
check_vm_err "$raw_log"

echo "## block cw20 contract methods <transfer> and <send>"
res=$(okbchaincli tx gov submit-proposal update-wasm-contract-method-blocked-list "${cw20contractAddr_ex}" "transfer,send" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "block <transfer> and <send> proposal_id: $proposal_id"
proposal_vote "$proposal_id"
cw20admin=$(okbchaincli query wasm contract "$cw20contractAddr_ex" "$QUERY_EXTRA" | jq '.contract_info.admin' | sed 's/\"//g')
if [[ $cw20admin != "" ]];
then
  exit 1
fi

res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --from captain $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "txhash: $tx_hash"
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
if [[ $raw_log != "execute wasm contract failed: $cw20contractAddr_0x method of contract transfer is not allowed: failed to execute message; message index: 0" ]];
then
  exit 1
fi;

res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"send":{"amount":"100","contract":"'$contractAddr'","msg":"eyJib25kIjp7fX0="}}' --from captain $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "txhash: $tx_hash"
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
if [[ $raw_log != "execute wasm contract failed: $cw20contractAddr_0x method of contract send is not allowed: failed to execute message; message index: 0" ]];
then
  exit 1
fi;

res=$(okbchaincli tx gov submit-proposal update-wasm-contract-method-blocked-list "$cw20contractAddr_ex" "transfer" --delete=true --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "unblock <transfer> proposal_id: $proposal_id"
proposal_vote "$proposal_id"

res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --from captain $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
raw_log=$(echo "$res" | jq '.raw_log')
check_vm_err "$raw_log"

res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"send":{"amount":"100","contract":"'$contractAddr'","msg":"eyJib25kIjp7fX0="}}' --from captain $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "txhash: $tx_hash"
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
if [[ $raw_log != "execute wasm contract failed: $cw20contractAddr_0x method of contract send is not allowed: failed to execute message; message index: 0" ]];
then
  exit 1
fi;

res=$(okbchaincli tx wasm store $contract_dir/test/burner.wasm --from captain $TX_EXTRA)
burner_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
echo "burner_code_id: $burner_code_id"

# block contract to execute
echo "## migrate cw20 contract to a new wasm code"
res=$(okbchaincli tx gov submit-proposal migrate-contract "$cw20contractAddr_ex" "$burner_code_id" '{"payout": "'$captain_ex'"}' --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

code_id=$(okbchaincli query wasm contract "$cw20contractAddr_ex" "$QUERY_EXTRA" | jq '.contract_info.code_id' | sed 's/\"//g')
if [[ $code_id != $burner_code_id ]];
then
  exit 1
fi;

echo "## call transfer method of cw20 contract after migrating which is expected to fail"
res=$(okbchaincli tx wasm execute "$cw20contractAddr_ex" '{"transfer":{"amount":"100","recipient":"'$admin18_ex'"}}' --from captain $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "txhash: $tx_hash"
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
if [[ $raw_log != "execute wasm contract failed: Error calling the VM: Error resolving Wasm function: Could not get export: Missing export execute: failed to execute message; message index: 0" ]];
then
  exit 1
fi;

echo "## gov set cw20 admin"
res=$(okbchaincli tx gov submit-proposal set-contract-admin $cw20contractAddr_ex $captain_ex --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

cw20admin=$(okbchaincli query wasm contract "$cw20contractAddr_ex" "$QUERY_EXTRA" | jq '.contract_info.admin' | sed 's/\"//g')
if [[ $cw20admin != $captain_0x ]];
then
  echo "unexpected cw20 admin: $cw20admin"
  exit 1
fi

# echo "## gov clear cw20 admin"
# res=$(okbchaincli tx gov submit-proposal clear-contract-admin $cw20contractAddr_ex --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
# proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
# echo "proposal_id: $proposal_id"
# proposal_vote "$proposal_id"

# cw20admin=$(okbchaincli query wasm contract "$cw20contractAddr_ex" "$QUERY_EXTRA" | jq '.contract_info.admin' | sed 's/\"//g')
# if [[ $cw20admin != "" ]];
# then
#   echo "cw20 admin expected to be nobody"
#   exit 1
# fi

# update whitelist
echo "## update deployment whitelist and store wasm code"
res=$(okbchaincli tx gov submit-proposal update-wasm-deployment-whitelist "ex1h0j8x0v9hs4eq6ppgamemfyu4vuvp2sl0q9p3v,ex15nnhqdf9sds0s063kaaretxj3ftlnzrguhfdeq" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

res=$(okbchaincli tx wasm store $contract_dir/test/burner.wasm --from admin18 $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "txhash: $tx_hash"
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
if [[ $raw_log != "unauthorized: Failed to create code, you are not allowed to upload contract as you are not on the authorized list: failed to execute message; message index: 0" ]];
then
  exit 1
fi;
res=$(okbchaincli tx wasm store $contract_dir/test/burner.wasm --from captain $TX_EXTRA)
tx_hash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "txhash: $tx_hash"
burner_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
echo "burner_code_id: $burner_code_id"

# claim okb from contract
res=$(okbchaincli tx wasm store $contract_dir/cw4-stake/artifacts/cw4_stake.wasm --from captain $TX_EXTRA)
echo "store cw4-stake succeed"
cw4_code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

res=$(okbchaincli tx wasm instantiate "$cw4_code_id" '{"denom":{"native":"okb"},"min_bond":"10","tokens_per_weight":"10","unbonding_period":{"height":1}}' --label cw4-stake --admin $captain_ex --from captain $TX_EXTRA)
echo "instantiate cw4-stake succeed"
cw4contractAddr_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
cw4contractAddr_ex=$(okbchaincli addr convert $cw4contractAddr_0x |  sed -n '2p' | grep -o 'ex1.*')
echo "cw4-stake contractAddr:---" $cw4contractAddr_ex $captain_0x
denom=$(okbchaincli query wasm contract-state smart "$cw4contractAddr_0x" '{"staked":{"address":"'$captain_0x'"}}' $QUERY_EXTRA | jq '.data.denom.native' | sed 's/\"//g')
if [[ $denom != "okb" ]];
then
  echo "unexpected native denom: $denom"
  exit 1
fi;

res=$(okbchaincli tx wasm execute "$cw4contractAddr_0x" '{"bond":{}}' --amount=10okb --from captain $TX_EXTRA)
amount=$(echo $res | jq '.logs[0].events[2].attributes[2].value' | sed 's/\"//g')
if [[ $amount != "10000000000000000000" ]];
then
  echo "unexpected bond amount: $amount"
  exit 1
fi;

stake=$(okbchaincli query wasm contract-state smart "$cw4contractAddr_0x" '{"staked":{"address":"'$captain_0x'"}}' $QUERY_EXTRA | jq '.data.stake' | sed 's/\"//g')
if [[ $stake != $amount ]];
then
  echo "unexpected stake amount: $stake"
  exit 1
fi

res=$(okbchaincli tx wasm execute "$cw4contractAddr_0x" '{"unbond":{"tokens":"'$stake'"}}' --from captain $TX_EXTRA)

stake=$(okbchaincli query wasm contract-state smart "$cw4contractAddr_0x" '{"staked":{"address":"'$captain_0x'"}}' $QUERY_EXTRA | jq '.data.stake' | sed 's/\"//g')
if [[ $stake != "0" ]];
then
  echo "unexpected stake amount after unbond: $stake"
  exit 1
fi

res=$(okbchaincli tx wasm execute "$cw4contractAddr_0x" '{"claim":{}}' --from captain $TX_EXTRA)
transferAmount=$(echo $res | jq '.logs[0].events[2].attributes[2].value' | sed 's/\"//g')
if [[ $transferAmount != "10.000000000000000000okb" ]];
then
  echo "unexpected transferAmount: $transferAmount"
  exit 1
fi

echo "claim okb from caontract succeed"

# update whitelist
res=$(okbchaincli tx gov submit-proposal update-wasm-deployment-whitelist "ex15s4kccjpw8dkgujhqfjw2mu47rc95rphlettns,ex1gwcgl6g8k5ncyanuhk4pz9js9mrdqt657xxa8z" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

res=$(okbchaincli tx wasm store $contract_dir/test/burner.wasm --from admin18 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log="unauthorized: Failed to create code, you are not allowed to upload contract as you are not on the authorized list: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log}" ]];
then
  echo "expect fail when update-wasm-deployment-whitelist is nobody"
  exit 1
fi;

echo "all tests passed! congratulations~"