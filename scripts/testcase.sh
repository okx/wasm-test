#!/bin/bash
set -o errexit -o nounset -o pipefail

source ./localnet-prepare.sh

. ./utils.sh
contract_dir=${PWD}/../contract
check_file_exit $contract_dir

QUERY_EXTRA="--node=$NODE"
TX_EXTRA_UNBLOCKED="--fees 0.01okt --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b async -y"
TX_EXTRA="--fees 0.01okt --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"

temp=$(exchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)
temp=$(exchaincli keys add --recover admin17 -m "antique onion adult slot sad dizzy sure among cement demise submit scare" -y)
temp=$(exchaincli keys add --recover admin18 -m "lazy cause kite fence gravity regret visa fuel tone clerk motor rent" -y)
captain=$(exchaincli keys show captain | jq -r '.eth_address')
admin18=$(exchaincli keys show admin18 | jq -r '.eth_address')
admin17=$(exchaincli keys show admin17 | jq -r '.eth_address')
proposal_deposit="100okt"

# usage:
#   proposal_vote {proposal_id}
proposal_vote() {
  ./vote.sh $1 $CHAIN_ID
}

#####################################################
########    rest deployment whitelist     #########
#####################################################
echo "## rest wasm code deployment whitelist"
res=$(exchaincli tx gov submit-proposal update-wasm-deployment-whitelist "nobody" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

#####################################################
#############       store code       ################
#####################################################

echo "## store...everybody nobody"
res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
echo "scf_log" $res
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log_prefix="unauthorized: Failed to create code, nobody allowed to upload contract: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log_prefix}" ]];
then
  echo "expect fail when instantiate contract with invalid amount"
  exit 1
fi;


echo "## store...only nobody"
res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-only-address=$(exchaincli keys show admin17 -a) --from captain $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log_prefix="unauthorized: Failed to create code, nobody allowed to upload contract: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log_prefix}" ]];
then
  echo "expect fail when instantiate contract with invalid amount"
  exit 1
fi;

#####################################################
########    update deployment whitelist     #########
#####################################################
echo "## update special address deployment whitelist"
res=$(exchaincli tx gov submit-proposal update-wasm-deployment-whitelist "$captain,$admin18" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

echo "## store...everybody special address"
res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-everybody=true --from admin17 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log_prefix="unauthorized: Failed to create code, you are not allowed to upload contract as you are not on the authorized list: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log_prefix}" ]];
then
  echo "expect fail when instantiate contract with invalid amount"
  exit 1
fi;

res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-everybody=true --from captain $TX_EXTRA)
cw20_code_id1=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')


echo "## store...only special address"
res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-only-address=$(exchaincli keys show admin17 -a) --from admin17 $TX_EXTRA)
raw_log=$(echo "$res" | jq '.raw_log' | sed 's/\"//g')
failed_log_prefix="unauthorized: Failed to create code, you are not allowed to upload contract as you are not on the authorized list: failed to execute message; message index: 0"
if [[ "${raw_log}" != "${failed_log_prefix}" ]];
then
  echo "expect fail when instantiate contract with invalid amount"
  exit 1
fi;

res=$(exchaincli tx wasm store $contract_dir/cw20-base/artifacts/cw20_base.wasm --instantiate-only-address=$(exchaincli keys show admin17 -a) --from captain $TX_EXTRA)
cw20_code_id3=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')

#####################################################
#########    instantiate contract      ##############
#####################################################

echo "## instantiate everybody..."
res=$(exchaincli tx wasm instantiate "$cw20_code_id1" '{"decimals":10,"initial_balances":[{"address":"'$captain'","amount":"100000000"}],"name":"my test token", "symbol":"mtt"}' --label test1 --admin "$captain" --from captain $TX_EXTRA)
echo "instantiate cw20 succeed"
echo $res | jq -r
if [[ $(echo "$res" | jq '.logs[0].events[0].attributes[0].key' | sed 's/\"//g') != "_contract_address" ]];
then
  echo "unexpected result of instantiate"
  exit 1
fi;

#####################################################
########    rest deployment whitelist     #########
#####################################################
echo "## rest wasm code deployment whitelist"
res=$(exchaincli tx gov submit-proposal update-wasm-deployment-whitelist "nobody" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

echo "all cases succeed~"