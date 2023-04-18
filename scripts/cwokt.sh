res=$(exchaincli tx wasm store artifacts/cwokt-aarch64.wasm --fees 0.01okt --from captain --gas=auto  -b block -y)
code_id=$(echo "$res" | jq -r '.logs[0].events[1].attributes[0].value')
echo "code_id: $code_id"
res=$(exchaincli tx wasm instantiate $code_id '{}' --label cwokt --admin 0xbbE4733d85bc2b90682147779DA49caB38C0aA1F --from captain --fees 0.01okt --gas 3000000 -y -b block)
contractAddr=$(echo "$res" | jq -r '.logs[0].events[0].attributes[0].value')
echo "contractAddr: $contractAddr"
exchaincli tx wasm execute 0x5A8D648DEE57b2fc90D98DC17fa887159b69638b '{"transfer":{"recipient":"0x2Bd4AF0C1D0c2930fEE852D07bB9dE87D8C07044"}}' --from captain --amount 1okt --fees 0.01okt --gas 30000000 -y -b block
