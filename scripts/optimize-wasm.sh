#!/bin/bash

. ./utils.sh

contract_dir=$(get_contract_dir $1)
check_file_exit $contract_dir
cd $contract_dir
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/rust-optimizer:0.12.6
