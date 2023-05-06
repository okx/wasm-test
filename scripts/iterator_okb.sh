source ./localnet-prepare-okb.sh
. ./utils.sh

TX_EXTRA="--fees 0.01okb --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"

temp=$(okbchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)
captain=$(okbchaincli keys show captain | jq -r '.eth_address')
proposal_deposit="100okb"

test_address() {
  cli="okbchaincli query wasm contract-state smart  $1 $2"
  res=$($cli)
  equal $3 $(echo "$res" | jq -r '.data')
}

test_case(){
  contract_dir=$(get_contract_dir iterator)
  check_file_exit $contract_dir
  useraddr_0x=$(okbchaincli keys show user | jq -r '.eth_address')
  res=$(okbchaincli tx wasm store $contract_dir/artifacts/iterator.wasm --fees 0.01okb --from user --gas=5000000 -b block -y)
  code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
  res=$(okbchaincli tx wasm instantiate "$code_id" "{}" --label test1 --admin ${useraddr_0x} --fees 0.1okb --gas=5000000 --from user -b block -y)
  raw_log=$(echo "$res" | jq -r '.raw_log')

  expect_log_prefix="{\"key\":\"action\",\"value\":\"instantiate\"}"
  contains $raw_log $expect_log_prefix

  contractAddr_0x=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')

  # case, ascending true, start nil, end nil
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":0}}' '0x014816AA63F9E6324240B596d0119c3ef544389F'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":5}}' '0x1f3FC034C0616582dC5BaC329Ba3AC038176E68E'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":10}}' '0x5A8D648DEE57b2fc90D98DC17fa887159b69638b'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":15}}' '0x8651e94972a56e69F3C0897d9E8faCbDAEb98386'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":20}}' '0xADf040519FE24bA9Df6670599B2dE7FD6049772f'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":25}}' '0xc461EDEEeC176Caeb16eA54a0480CDCD4aBf6728'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":29}}' '0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"","index":30}}' ''

  # case, ascending flase, start nil, end nil
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":0}}' '0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":5}}' '0xae1B7Aae07cb4f40b967f2d94dE5C3758c3d5C45'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":10}}' '0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":15}}' '0x75a8Fe4b9929769ee37a61612B486Cdf343f2144'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":20}}' '0x574CFB6397e62F6C725B93587d069C0dFE787F33'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":25}}' '0x1BaaA4301268D67BbA3e7a8BC6Ca62992695648D'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":29}}' '0x014816AA63F9E6324240B596d0119c3ef544389F'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"","end":"","index":30}}' ''

  # case, ascending true, start nil, end 0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":0}}' '0x014816AA63F9E6324240B596d0119c3ef544389F'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":5}}' '0x1f3FC034C0616582dC5BaC329Ba3AC038176E68E'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":10}}' '0x5A8D648DEE57b2fc90D98DC17fa887159b69638b'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":15}}' '0x8651e94972a56e69F3C0897d9E8faCbDAEb98386'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":20}}' '0xADf040519FE24bA9Df6670599B2dE7FD6049772f'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":25}}' '0xc461EDEEeC176Caeb16eA54a0480CDCD4aBf6728'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":29}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"","end":"0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD","index":30}}' ''

  # case, ascending false, start 0x014816AA63F9E6324240B596d0119c3ef544389F, end nil
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":0}}' '0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":5}}' '0xae1B7Aae07cb4f40b967f2d94dE5C3758c3d5C45'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":10}}' '0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":15}}' '0x75a8Fe4b9929769ee37a61612B486Cdf343f2144'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":20}}' '0x574CFB6397e62F6C725B93587d069C0dFE787F33'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":25}}' '0x1BaaA4301268D67BbA3e7a8BC6Ca62992695648D'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":29}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x014816AA63F9E6324240B596d0119c3ef544389F","end":"","index":30}}' ''

  # case, ascending true, start 0x574CFB6397e62F6C725B93587d069C0dFE787F33, end 0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":0}}' '0x5A8D648DEE57b2fc90D98DC17fa887159b69638b'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":5}}' '0x8651e94972a56e69F3C0897d9E8faCbDAEb98386'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":8}}' '0x9866e0D7E06b447A23a96cC4f25Bc0D686A5B555'
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":9}}' ''

  # case, ascending false, start 0x574CFB6397e62F6C725B93587d069C0dFE787F33, end 0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":0}}' '0x9866e0D7E06b447A23a96cC4f25Bc0D686A5B555'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":5}}' '0x71efC79707B59A887bDd37CaCB899048DD276862'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":8}}' '0x5A8D648DEE57b2fc90D98DC17fa887159b69638b'
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","end":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","index":9}}' ''


  # case, ascending true, start 0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1 end 0x574CFB6397e62F6C725B93587d069C0dFE787F33,
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":0}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":5}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":8}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":true,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":9}}' ''

  # case, ascending false, start 0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1 end 0x574CFB6397e62F6C725B93587d069C0dFE787F33,
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":-1}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":0}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":5}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":8}}' ''
  test_address $contractAddr_0x '{"get_address":{"ascending":false,"start":"0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1","end":"0x574CFB6397e62F6C725B93587d069C0dFE787F33","index":9}}' ''

  echo "case $1 succeed~"
}

echo "start"
okbchaincli keys add user --recover -m "rifle purse jacket embody deny win where finish door awful space pencil" -y >/dev/null 2>&1
temp=$(okbchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y)

res=$(okbchaincli tx send captain $(okbchaincli keys show user -a) 1okb --fees 0.001okb -y -b block)

for (( i=0; i<20; i++ ))
do
    test_case $i
done

echo "all cases succeed~"
