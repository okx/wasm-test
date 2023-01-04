#!/bin/bash
set -e
get_contract_dir() {
  contract_dir=${PWD}/../contract/${1}
  echo $contract_dir
}

check_file_exit() {
if [ ! -d "$1" ]; then
    echo "ERROR: 不存在合约${1}"
    exit 1
fi
return
}
