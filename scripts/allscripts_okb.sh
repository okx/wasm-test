#!/bin/bash 
set -x
date
echo "--------------all_testcase_0x_okb.sh"
sh  all_testcase_0x_okb.sh
echo "--------------all_testcase_ex_okb.sh"
sh  all_testcase_ex_okb.sh

echo "--------------all_testcase_okb.sh"
sh  all_testcase_okb.sh
echo "--------------cw20-pot-okb.sh"
sh  cw20-pot-okb.sh
echo "--------------cw20-pot-reply-okb.sh"
sh  cw20-pot-reply-okb.sh
echo "--------------cw20_migrate_okb.sh"
sh  cw20_migrate_okb.sh
echo "--------------erc20_okb.sh"
sh  erc20_okb.sh
echo "--------------escrow_okb.sh"
sh  escrow_okb.sh
echo "--------------op-addr-okb.sh"
sh  op-addr-okb.sh
echo "--------------testcase_0x_okb.sh"
sh  testcase_0x_okb.sh
echo "--------------testcase_ex_okb.sh"
sh  testcase_ex_okb.sh
echo "--------------wasm-testnet-okb.sh"
sh  wasm-testnet-okb.sh
echo "--------------wasm-testnet_0x_okb.sh"
sh  wasm-testnet_0x_okb.sh
echo "--------------wasm-testnet_ex_okb.sh"
sh  wasm-testnet_ex_okb.sh
echo "--------------wasm-whitelist_okb.sh"
sh  wasm-whitelist_okb.sh
echo "--------------iterator_okb.sh"
sh  iterator_okb.sh

date