#!/bin/bash

NODE_FLAGS=""

function testnetvote() {
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval00 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval01-1 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval02-4 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval03-5 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval04-5 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval05-4 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval06-3 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval07 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval08-4 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval09-5 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval10 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval11-4 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval12-3 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval13-5 --chain-id=$2 $NODE_FLAGS
    exchaincli tx gov vote $1 yes -y -b block --fees 0.004okt --gas 2000000 --from testval14-3 --chain-id=$2 $NODE_FLAGS
}

function localnetvote() {
  echo "localnet start"
  exchaincli tx gov vote $1 yes -y -b block --fees 0.004okt --gas 2000000 --from captain --chain-id=$2 $NODE_FLAGS
}

if [ -n "$3" ]
then
  NODE_FLAGS="--node=$3"
else
  NODE_FLAGS=""
fi

case "$2" in
  exchain-65)
    testnetvote $1 $2
    ;;
  exchain-66)
    echo
    echo "ERROR: mainnet is not support, '$2'"
    echo
    exit 1
    ;;
  exchain-67)
    localnetvote $1 $2
    ;;
  *)
    echo
    echo "ERROR: unknown chain-id-> '$2'"
    echo
    exit 1
    ;;
esac
