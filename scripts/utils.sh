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

contains() {
  if [[ "$1" != *"$2"* ]];
  then
    echo "expect contains: $2"
    echo "got: $1"
    exit 1
  fi;
}

nocontains() {
  if [[ "$1" == *"$2"* ]];
  then
      echo "$1"
      echo "contains: $2"
      exit 1
  fi;
}

equal() {
  if [[ "$1" != "$2" ]];
    then
      echo "expect: $2"
      echo "got: $1"
      exit 1
    fi;
}