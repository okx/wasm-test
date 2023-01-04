. ./utils.sh

contract_dir=$(get_contract_dir escrow)
check_file_exit $contract_dir

useraddr=$(exchaincli keys show user -a)

res=$(exchaincli tx wasm store ${contract_dir}/artifacts/cw_escrow-aarch64.wasm --fees 0.01okt --from user --gas=2000000 -b block -y)
echo "store code..."
echo $res
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm instantiate "$code_id" "{\"arbiter\":\"${useraddr}\",\"end_height\":100000,\"recipient\":\"ex190227rqaps5nplhg2tg8hww7slvvquzy0qa0l0\"}" --label test1 --admin $useraddr --fees 0.001okt --from user -b block -y)
contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
echo "instantiate contract..."
echo $res
#exchaincli tx send ex1h0j8x0v9hs4eq6ppgamemfyu4vuvp2sl0q9p3v $contractAddr 999okt --fees 0.01okt -y -b block
exchaincli tx wasm execute "$contractAddr" '{"approve":{"quantity":[{"amount":"1","denom":"okt"}]}}' --amount 888okt --fees 0.001okt --from user -b block -y
