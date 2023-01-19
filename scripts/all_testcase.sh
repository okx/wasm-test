. ./utils.sh


exchaincli keys add user --recover -m "rifle purse jacket embody deny win where finish door awful space pencil" -y >/dev/null 2>&1

res=$(exchaincli tx send captain $(exchaincli keys show user -a) 1000okt --fees 0.001okt -y -b block)

contract_dir=$(get_contract_dir testcase)
check_file_exit $contract_dir

useraddr=$(exchaincli keys show user -a)
res=$(exchaincli tx wasm store $contract_dir/artifacts/testcase.wasm --fees 0.01okt --from user --gas=2000000 -b block -y)
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr} --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix

contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm execute "$contractAddr" '{"transfer":{"amount":"100","recipient":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}' --fees 0.001okt --from user -b block -y)


res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr} --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')
expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"

contains $raw_log $expect_log_prefix
contractAddr1=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
#echo " ========================================================== "
#echo "## show all codes uploaded ##"
#exchaincli query wasm list-code

echo " ========================================================== "
echo "## show contract info by contract addr ##"
exchaincli query wasm contract "$contractAddr"

#echo " ========================================================== "
#echo "## show contract update history by contract addr ##"
#exchaincli query wasm contract-history "$contractAddr"

echo " ========================================================== "
echo "## query contract state by contract addr ##"
echo "#### all state"
exchaincli query wasm contract-state all "$contractAddr"
echo "#### raw state"
exchaincli query wasm contract-state raw "$contractAddr" 0006636F6E666967636F6E7374616E7473
echo "#### smart state"
exchaincli query wasm contract-state smart "$contractAddr" "{\"balance\":{\"address\":\"${useraddr}\"}}"
exchaincli query wasm contract-state smart "$contractAddr" '{"balance":{"address":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}'

res=$(exchaincli tx send captain $contractAddr 1000okt --fees 0.001okt -y -b block)



addr1=$(exchaincli keys add addr1 -y 2>&1 | jq -r '.address')
addr2=$(exchaincli keys add addr2 -y 2>&1 | jq -r '.address')
echo "1.#### 1 submsg success"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000001" $res

echo "2.#### 1 submsg failed"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="insufficient funds: insufficient account funds"
contains "$raw_log" "$failed_log"

echo "3.#### 2 submsg all success"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000002" $res

res=$(exchaincli query account $addr2 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000001" $res

echo "4.#### 2 submsg 1 success 1 failed"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="insufficient funds: insufficient account funds"
contains "$raw_log" "$failed_log"


echo "5.#### 2 submsg all failed"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"bankmsg\",\"to\":\"$addr2\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="insufficient funds: insufficient account funds"
contains "$raw_log" "$failed_log"

echo "6.#### 1 submsg success with gaslimit"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"21000\"}]}}" --fees 0.001okt --from user -b block -y)
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000003" $res

echo "7.#### 1 submsg failed with gaslimit(out of gas)"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"100\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="out of gas: SubMsg hit gas limit"
contains "$raw_log" "$failed_log"

echo "8.#### 1 submsg failed with gaslimit(addr err)"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"ex111\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="invalid address: Invalid recipient address (decoding bech32 failed: invalid bech32 "
contains "$raw_log" "$failed_log"

echo "9.#### 1 submsg failed with gaslimit(module addr)"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="unauthorized: ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2 is not allowed to receive funds"
contains "$raw_log" "$failed_log"

echo "10.#### 1 submsg failed with stakingmsg"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"stakingmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="unknown message from the contract: no handler found"
contains "$raw_log" "$failed_log"

echo "11.#### 1 submsg failed with distrmsg"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"distrmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="unknown message from the contract: no handler found"
contains "$raw_log" "$failed_log"

echo "12.#### 1 submsg failed with govmsg"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"govmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="unknown message from the contract: no handler found"
contains "$raw_log" "$failed_log"

echo "13.#### 1 submsg failed with ibcmsg"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"ibcmsg\",\"to\":\"ex17xpfvakm2amg962yls6f84z3kell8c5lcs49z2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="unknown message from the contract: no handler found: submessages: dispatch"
contains "$raw_log" "$failed_log"

echo "14.#### 2 submsg one bankmsg one stakingmsg failed"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"},{\"calltype\":\"stakingmsg\",\"to\":\"$addr2\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"none\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="unknown message from the contract: no handler found: submessages: dispatch"
contains "$raw_log" "$failed_log"
res=$(exchaincli query account $addr2 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000001" $res


echo "15.#### 1 bankmsg success replySuccess success"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{\"key\":\"reply_success\",\"value\":\"1\"}'
contains "$raw_log" "$reply_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000004" $res


echo "16.#### 1 bankmsg success replySuccess failed"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="The Contract addr is not expect: 0"
contains "$raw_log" "$failed_log"


echo "17.#### 1 bankmsg failed replySuccess"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"success\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="insufficient funds: insufficient account funds"
contains "$raw_log" "$failed_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000004" $res


echo "18.#### 1 bankmsg failed replySuccess"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"success\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
failed_log="insufficient funds: insufficient account funds"
contains "$raw_log" "$failed_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000004" $res


echo "19.#### 1 bankmsg success replyNever"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{\"key\":\"reply_success\"}'
nocontains "$raw_log" "$reply_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000005" $res

echo "20.#### 1 bankmsg failed replyNever"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{\"key\":\"reply_success\"}'
nocontains "$raw_log" "$reply_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000005" $res


echo "21.#### 1 bankmsg success replyError"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{\"key\":\"reply_success\"}'
nocontains "$raw_log" "$reply_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000006" $res



echo "22.#### 1 bankmsg failed replyError success"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"error\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{\"key\":\"reply_success\",\"value\":\"1\"}'
contains "$raw_log" "$reply_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000006" $res

echo "23.#### 1 bankmsg failed replyError error"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"error\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='The Contract addr is not expect: 0'
contains "$raw_log" "$reply_log"


echo "24.#### 1 bankmsg success replyAlways success"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{\"key\":\"reply_success\",\"value\":\"1\"}'
contains "$raw_log" "$reply_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000007" $res

echo "25.#### 1 bankmsg success replyAlways error"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"1\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='The Contract addr is not expect: 0'
contains "$raw_log" "$reply_log"

echo "26.#### 1 bankmsg failed replyAlways success"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"always\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{\"key\":\"reply_success\",\"value\":\"1\"}'
contains "$raw_log" "$reply_log"
res=$(exchaincli query account $addr1 2>&1 | jq -r '.value.coins[0].amount')
equal "0.000000000000000007" $res

echo "27.#### 1 bankmsg failed replyAlways error"
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"bankmsg\",\"to\":\"$addr1\",\"subcall\":\"\",\"amount\":\"10000000000000000000000\",\"replyon\":\"always\",\"replyid\":\"0\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --from user -b block -y)
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='The Contract addr is not expect: 0'
contains "$raw_log" "$reply_log"


echo "28.#### 1 wasmmsg success replySuccess success"
subcall=$(echo '{"do_reply":{}}' | base64)
res=$(exchaincli tx wasm execute "$contractAddr" "{\"call_submsg\":{\"call\":[{\"calltype\":\"wasmmsg\",\"to\":\"$contractAddr1\",\"subcall\":\"$subcall\",\"amount\":\"1\",\"replyon\":\"never\",\"replyid\":\"1\",\"gaslimit\":\"0\"}]}}" --fees 0.001okt --gas 2000000 --from user -b block -y)
echo "contract",$contractAddr
echo "contract1",$contractAddr1
echo $res
raw_log=$(echo "$res" | jq '.raw_log')
reply_log='{ "key": "reply_success", "value": "1" }'
contains "$raw_log" "$reply_log"

#exchaincli tx wasm execute "$contractAddr" '{"do_reply":{}}' --fees 0.001okt --from user -b block -y

