set -x

cargo wasm

cargo run-script optimize

res=$(exchaincli tx wasm store ./artifacts/keccak_test.wasm --fees 0.01okt --from captain --gas=2000000 -b block -y)
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm instantiate "$code_id" "{}" --label test1 --admin "0xbbE4733d85bc2b90682147779DA49caB38C0aA1F" --fees 0.001okt --from captain -b block -y)
raw_log=$(echo "$res" | jq -r '.raw_log')

contractAddr_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm execute "$contractAddr_0x" '{"test":{"mode": 0, "count": 1, "data": "1ff5c235b3c317d054b80b4bf0a8038bd727d180872d2491a7edef4f949c4135"}}' --gas auto --fees 1okt --gas-adjustment 1.3 --from captain -b block -y)
res=$(exchaincli tx wasm execute "$contractAddr_0x" '{"test":{"mode": 1, "count": 1, "data": "1ff5c235b3c317d054b80b4bf0a8038bd727d180872d2491a7edef4f949c4135"}}' --gas auto --fees 1okt --gas-adjustment 1.3 --from captain -b block -y)
res=$(exchaincli tx wasm execute "$contractAddr_0x" '{"test":{"mode": 2, "count": 1, "data": "1ff5c235b3c317d054b80b4bf0a8038bd727d180872d2491a7edef4f949c4135"}}' --gas auto --fees 1okt --gas-adjustment 1.3 --from captain -b block -y)
res=$(exchaincli tx wasm execute "$contractAddr_0x" '{"test":{"mode": 3, "count": 1, "data": "0x4C12e733e58819A1d3520f1E7aDCc614Ca20De64"}}' --gas auto --fees 1okt --gas-adjustment 1.3 --from captain -b block -y)
