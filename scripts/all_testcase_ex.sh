source ./localnet-prepare.sh
. ./utils.sh

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

echo "start"
exchaincli keys add user --recover -m "rifle purse jacket embody deny win where finish door awful space pencil" -y >/dev/null 2>&1
temp=$(exchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)

res=$(exchaincli tx send captain $(exchaincli keys show user -a) 1okt --fees 0.001okt -y -b block)

contract_dir=$(get_contract_dir testcase)
check_file_exit $contract_dir

useraddr_0x=$(exchaincli keys show user | jq -r '.eth_address')
res=$(exchaincli tx wasm store $contract_dir/artifacts/testcase.wasm --fees 0.01okt --from user --gas=2000000 -b block -y)
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix

contractAddr_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm execute "$contractAddr_0x" '{"transfer":{"amount":"100","recipient":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}' --fees 0.001okt --from user -b block -y)
contractAddr_ex=$(exchaincli addr convert $contractAddr_0x |  sed -n '2p' | grep -o 'ex1.*')
res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix
contractAddr1_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
contractAddr1_ex=$(exchaincli addr convert $contractAddr1_0x |  sed -n '2p' | grep -o 'ex1.*')
res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix
contractAddr2_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
contractAddr2_ex=$(exchaincli addr convert $contractAddr2_0x |  sed -n '2p' | grep -o 'ex1.*')

res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix
contractAddr3_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
contractAddr3_ex=$(exchaincli addr convert $contractAddr3_0x |  sed -n '2p' | grep -o 'ex1.*')
echo "con3" $contractAddr1_ex $contractAddr2_ex $contractAddr3_ex
#echo " ========================================================== "
#echo "## show all codes uploaded ##"
#exchaincli query wasm list-code

echo " ========================================================== "
echo "## show contract info by contract addr ##"
exchaincli query wasm contract "$contractAddr_ex"

#echo " ========================================================== "
#echo "## show contract update history by contract addr ##"
#exchaincli query wasm contract-history "$contractAddr_ex"

echo " ========================================================== "
echo "## query contract state by contract addr ##"
echo "#### all state"
exchaincli query wasm contract-state all "$contractAddr_ex"
echo "#### raw state"
exchaincli query wasm contract-state raw "$contractAddr_ex" 0006636F6E666967636F6E7374616E7473
echo "#### smart state"
exchaincli query wasm contract-state smart "$contractAddr_ex" "{\"balance\":{\"address\":\"${useraddr_0x}\"}}"
#exchaincli query wasm contract-state smart "$contractAddr_ex" '{"balance":{"address":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}' not support

res=$(exchaincli tx send captain $contractAddr_ex 1okt --fees 0.001okt -y -b block)

function check_address_is_not_normalized {
  if [[ $1 != *"execute wasm contract failed: Generic error: addr_validate errored: Address is not normalized: failed to execute message; message index: 0"* ]]; then
    echo "unexcepted output" $1
    exit 1
  fi
}

function check_address_decode_failed() {
    if [[ $1 != *"execute wasm contract failed: Generic error: addr_validate errored: decoding bech32 failed: invalid bech32 string length 5: failed to execute message; message index: 0"* ]]; then
        echo "unexcepted output" $1
        exit 1
      fi
}


addr1_ex=$(exchaincli keys add addr1_ex -y 2>&1 | jq -r '.address')  #ex
addr2_ex=$(exchaincli keys add addr2_ex -y 2>&1 | jq -r '.address')  #ex
echo "1.#### 1 submsg success"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "2.#### 1 submsg failed"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "3.#### 2 submsg all success"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "4.#### 2 submsg 1 success 1 failed"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "5.#### 2 submsg all failed"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "6.#### 1 submsg success with gaslimit"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"21000\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "7.#### 1 submsg failed with gaslimit(out of gas)"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"100\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "8.#### 1 submsg failed with gaslimit(addr err)"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"ex111\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_decode_failed "$raw_log"

echo "9.#### 1 submsg failed with gaslimit(module addr)"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "10.#### 1 submsg failed with stakingmsg"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"stakingmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "11.#### 1 submsg failed with distrmsg"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"distrmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "12.#### 1 submsg failed with govmsg"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"govmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "13.#### 1 submsg failed with ibcmsg"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"ibcmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "14.#### 2 submsg one bankmsg one stakingmsg failed"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"stakingmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "15.#### 1 bankmsg success replySuccess success"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "16.#### 1 bankmsg success replySuccess failed"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "17.#### 1 bankmsg failed replySuccess"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "18.#### 1 bankmsg failed replySuccess"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "19.#### 1 bankmsg success replyNever"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "20.#### 1 bankmsg failed replyNever"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "21.#### 1 bankmsg success replyError"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "22.#### 1 bankmsg failed replyError success"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "23.#### 1 bankmsg failed replyError error"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"error\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "24.#### 1 bankmsg success replyAlways success"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "25.#### 1 bankmsg success replyAlways error"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "26.#### 1 bankmsg failed replyAlways success"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "27.#### 1 bankmsg failed replyAlways error"
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "28.#### 2 level wasmmsg call success"
subcall=$(echo '{"do_reply":{}}' | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "29.#### 3 level wasmmsg call success"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "30.#### 3 level wasmmsg call the second failed"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "31.#### 3 level wasmmsg call the third failed"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "32.#### 3 level wasmmsg call repleySuccess success"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "33.#### 3 level wasmmsg call repleySuccess failed"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "34.#### 3 level wasmmsg error call repleySuccess"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "35.#### 3 level wasmmsg error call repleyNever "
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "36.#### 3 level wasmmsg call repleyNever"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "37.#### 3 level wasmmsg error call repleyError "
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "38.#### 3 level wasmmsg call repleyError"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "39.#### 3 level wasmmsg call repleyAlways success"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "40.#### 3 level wasmmsg call repleyAlways failed"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "41.#### 3 level wasmmsg errorcall repleyAlways success"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "42.#### 3 level wasmmsg errorcall repleyAlways failed"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(exchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"
echo "all cases succeed~"

#exchaincli tx wasm execute "$contractAddr" '{"do_reply":{}}' --fees 0.001okt --from user -b block -y

