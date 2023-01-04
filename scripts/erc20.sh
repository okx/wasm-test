. ./utils.sh

contract_dir=$(get_contract_dir erc20)
check_file_exit $contract_dir

useraddr=$(exchaincli keys show user -a)
res=$(exchaincli tx wasm store $contract_dir/artifacts/cw_erc20.wasm --fees 0.01okt --from user --gas=2000000 -b block -y)
echo $res
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm instantiate "$code_id" "{\"decimals\":10,\"initial_balances\":[{\"address\":\"${useraddr}\",\"amount\":\"100000000\"}],\"name\":\"my test token\", \"symbol\":\"MTT\"}" --label test1 --admin ${useraddr} --fees 0.001okt --from user -b block -y)
contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
exchaincli tx wasm execute "$contractAddr" '{"transfer":{"amount":"100","recipient":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}' --fees 0.001okt --from user -b block -y

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
exchaincli query wasm contract-state smart "$contractAddr" '{"balance":{"address":"ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq"}}'
