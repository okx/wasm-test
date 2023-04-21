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

echo "## update wasm code deployment whitelist"
res=$(okbchaincli tx gov submit-proposal update-wasm-deployment-whitelist "all" --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
echo $res
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

echo "start"
okbchaincli keys add user --recover -m "rifle purse jacket embody deny win where finish door awful space pencil" -y >/dev/null 2>&1
temp=$(okbchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)

res=$(okbchaincli tx send captain $(okbchaincli keys show user -a) 1okb --fees 0.001okb -y -b block)

contract_dir=$(get_contract_dir testcase)
check_file_exit $contract_dir

useraddr_0x=$(okbchaincli keys show user | jq -r '.eth_address')
res=$(okbchaincli tx wasm store $contract_dir/artifacts/testcase.wasm --fees 0.01okb --from user --gas=2000000 -b block -y)
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(okbchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix

contractAddr_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
res=$(okbchaincli tx wasm execute "$contractAddr_0x" '{"transfer":{"amount":"100","recipient":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}' --fees 0.001okb --from user -b block -y)
contractAddr_ex=$(okbchaincli addr convert $contractAddr_0x |  sed -n '2p' | grep -o 'ex1.*')
res=$(okbchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix
contractAddr1_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
contractAddr1_ex=$(okbchaincli addr convert $contractAddr1_0x |  sed -n '2p' | grep -o 'ex1.*')
res=$(okbchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix
contractAddr2_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
contractAddr2_ex=$(okbchaincli addr convert $contractAddr2_0x |  sed -n '2p' | grep -o 'ex1.*')

res=$(okbchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr_0x}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr_0x} --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix
contractAddr3_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
contractAddr3_ex=$(okbchaincli addr convert $contractAddr3_0x |  sed -n '2p' | grep -o 'ex1.*')
echo "con3" $contractAddr1_ex $contractAddr2_ex $contractAddr3_ex
#echo " ========================================================== "
#echo "## show all codes uploaded ##"
#okbchaincli query wasm list-code

echo " ========================================================== "
echo "## show contract info by contract addr ##"
okbchaincli query wasm contract "$contractAddr_ex"

#echo " ========================================================== "
#echo "## show contract update history by contract addr ##"
#okbchaincli query wasm contract-history "$contractAddr_ex"

echo " ========================================================== "
echo "## query contract state by contract addr ##"
echo "#### all state"
okbchaincli query wasm contract-state all "$contractAddr_ex"
echo "#### raw state"
okbchaincli query wasm contract-state raw "$contractAddr_ex" 0006636F6E666967636F6E7374616E7473
echo "#### smart state"
okbchaincli query wasm contract-state smart "$contractAddr_ex" "{\"balance\":{\"address\":\"${useraddr_0x}\"}}"
#okbchaincli query wasm contract-state smart "$contractAddr_ex" '{"balance":{"address":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}' not support

res=$(okbchaincli tx send captain $contractAddr_ex 1okb --fees 0.001okb -y -b block)

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


addr1_ex=$(okbchaincli keys add addr1_ex -y 2>&1 | jq -r '.address')  #ex
addr2_ex=$(okbchaincli keys add addr2_ex -y 2>&1 | jq -r '.address')  #ex
echo "1.#### 1 submsg success"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "2.#### 1 submsg failed"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "3.#### 2 submsg all success"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "4.#### 2 submsg 1 success 1 failed"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "5.#### 2 submsg all failed"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "6.#### 1 submsg success with gaslimit"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"21000\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "7.#### 1 submsg failed with gaslimit(out of gas)"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"100\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "8.#### 1 submsg failed with gaslimit(addr err)"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"ex111\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_decode_failed "$raw_log"

echo "9.#### 1 submsg failed with gaslimit(module addr)"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "10.#### 1 submsg failed with stakingmsg"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"stakingmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "11.#### 1 submsg failed with distrmsg"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"distrmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "12.#### 1 submsg failed with govmsg"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"govmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "13.#### 1 submsg failed with ibcmsg"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"ibcmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "14.#### 2 submsg one bankmsg one stakingmsg failed"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"stakingmsg\",\"to\":\"$addr2_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "15.#### 1 bankmsg success replySuccess success"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "16.#### 1 bankmsg success replySuccess failed"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "17.#### 1 bankmsg failed replySuccess"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "18.#### 1 bankmsg failed replySuccess"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "19.#### 1 bankmsg success replyNever"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "20.#### 1 bankmsg failed replyNever"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "21.#### 1 bankmsg success replyError"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "22.#### 1 bankmsg failed replyError success"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "23.#### 1 bankmsg failed replyError error"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"error\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "24.#### 1 bankmsg success replyAlways success"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "25.#### 1 bankmsg success replyAlways error"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "26.#### 1 bankmsg failed replyAlways success"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "27.#### 1 bankmsg failed replyAlways error"
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "28.#### 2 level wasmmsg call success"
subcall=$(echo '{"do_reply":{}}' | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "29.#### 3 level wasmmsg call success"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "30.#### 3 level wasmmsg call the second failed"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "31.#### 3 level wasmmsg call the third failed"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "32.#### 3 level wasmmsg call repleySuccess success"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "33.#### 3 level wasmmsg call repleySuccess failed"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "34.#### 3 level wasmmsg error call repleySuccess"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "35.#### 3 level wasmmsg error call repleyNever "
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "36.#### 3 level wasmmsg call repleyNever"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"


echo "37.#### 3 level wasmmsg error call repleyError "
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "38.#### 3 level wasmmsg call repleyError"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "39.#### 3 level wasmmsg call repleyAlways success"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "40.#### 3 level wasmmsg call repleyAlways failed"
subcall2=$(echo '{"do_reply":{}}' | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "41.#### 3 level wasmmsg errorcall repleyAlways success"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2_ex\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"

echo "42.#### 3 level wasmmsg errorcall repleyAlways failed"
subcall2=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"errorcall1\",\"to\":\"$addr1_ex\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" | base64)
subcall1=$(echo "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr2\",\"subcall\":\"$subcall2\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" | base64)
res=$(okbchaincli tx wasm execute "$contractAddr_ex" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1_ex\",\"subcall\":\"$subcall1\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okb --gas 2000000 --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
check_address_is_not_normalized "$raw_log"
echo "all cases succeed~"

#okbchaincli tx wasm execute "$contractAddr" '{"do_reply":{}}' --fees 0.001okb --from user -b block -y

