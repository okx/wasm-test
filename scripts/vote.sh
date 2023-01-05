#!/bin/bash

function testnetvote() {
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval00
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval01-1
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval02-4
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval03-5
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval04-5
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval05-4
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval06-3
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval07
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval08-4
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval09-5
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval10
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval11-4
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval12-3
    exchaincli tx gov vote $1 yes -y -b sync --fees 0.004okt --gas 2000000 --from testval13-5
    exchaincli tx gov vote $1 yes -y -b block --fees 0.004okt --gas 2000000 --from testval14-3
}

function localnetvote() {
  echo "localnet start"
  exchaincli tx gov vote $1 yes -y -b block --fees 0.004okt --gas 2000000 --from captain
}

case "$2" in
  exchain-65)
    testnetvote $1
    ;;
  exchain-66)
    echo
    echo "ERROR: mainnet is not support, '$2'"
    echo
    exit 1
    ;;
  exchain-67)
    localnetvote $1
    ;;
  *)
    echo
    echo "ERROR: unknown chain-id-> '$2'"
    echo
    exit 1
    ;;
esac
