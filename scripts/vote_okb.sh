#!/bin/bash

NODE_FLAGS=""


function testnetvote() {
#    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val0 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val1 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val2 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val3 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val4 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val5 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val6 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val7 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val8 --chain-id=$2 $NODE_FLAGS
    okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from testnet-val9 --chain-id=$2 $NODE_FLAGS
#    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val10 --chain-id=$2 $NODE_FLAGS
#    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val11 --chain-id=$2 $NODE_FLAGS
#    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val12 --chain-id=$2 $NODE_FLAGS
#    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val0 --chain-id=$2 $NODE_FLAGS
#    okbchaincli tx gov vote $1 yes -y -b sync --fees 0.004okb --gas 2000000 --from testnet-val0 --chain-id=$2 $NODE_FLAGS
#    okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from testval14-3 --chain-id=$2 $NODE_FLAGS
}

function localnetvote() {
  echo "localnet start"
  okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from captain --chain-id=$2 $NODE_FLAGS
}

function localnetvote4v() {
  echo "localnet 4v start"
  okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from val0 --chain-id=$2 $NODE_FLAGS
  okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from val1 --chain-id=$2 $NODE_FLAGS
  okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from val2 --chain-id=$2 $NODE_FLAGS
  okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from val3 --chain-id=$2 $NODE_FLAGS
}

function devnetvote(){
   echo "devnet vote start"
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val0 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val1 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val2 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val3 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val4 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val5 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val6 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val7 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val8 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val9 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val10 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val11 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val12 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val13 --chain-id=$2 $NODE_FLAGS
   okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val14 --chain-id=$2 $NODE_FLAGS
  # okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val15 --chain-id=$2 $NODE_FLAGS
  # okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val16 --chain-id=$2 $NODE_FLAGS
  # okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val17 --chain-id=$2 $NODE_FLAGS
  # okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val18 --chain-id=$2 $NODE_FLAGS
  # okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val19 --chain-id=$2 $NODE_FLAGS
  # okbchaincli tx gov vote $1 yes -y -b block --fees 0.004okb --gas 2000000 --from devnet_val20 --chain-id=$2 $NODE_FLAGS
}

if [ -n "$3" ]
then
  NODE_FLAGS="--node=$3"
else
  NODE_FLAGS=""
fi

case "$2" in
  okbchain-197)
	 devnetvote $1 $2
	 ;;
  okbchaintest-195)
    testnetvote $1 $2
    ;;
  okbchain-196)
    echo
    echo "ERROR: mainnet is not support, '$2'"
    echo
    exit 1
    ;;
  okbchain-67)
	 vcount=$(okbchaincli query staking validators $NODE_FLAGS | grep "moniker" | wc -l | sed 's/ //g')
	 if [[ $vcount == 4 ]];
	 then
	 	 localnetvote4v $1 $2
	 elif [[ $vcount == 21 ]];
	 then
	 	 devnetvote $1 $2
    else
    	 localnetvote $1 $2
    fi
    ;;
  *)
    echo
    echo "ERROR: unknown chain-id-> '$2'"
    echo
    exit 1
    ;;
esac
