rm -rf ~/.exchaincli

export CHAIN_ID="exchain-65"
export NODE="https://exchaintesttmrpc.okex.org"

exchaincli config chain-id $CHAIN_ID
exchaincli config output json
exchaincli config indent true
exchaincli config trust-node true
exchaincli config keyring-backend test
exchaincli config node $NODE

# you must keys add testnet val key as follow. testnet val keyname must be equal vote.sh testnet val keyname

#exchaincli keys add testval00 --recover -m "<menomic>" --coin-type 996 -y
#exchaincli keys add testval01-1 --recover -m "<menomic>" -y
#exchaincli keys add testval02-4 --recover -m "<menomic>" -y
#exchaincli keys add testval03-5 --recover -m "<menomic>" -y
#exchaincli keys add testval04-5 --recover -m "<menomic>" -y
#exchaincli keys add testval05-4 --recover -m "<menomic>" -y
#exchaincli keys add testval06-3 --recover -m "<menomic>" -y
#exchaincli keys add testval07 --recover -m "<menomic>" --coin-type 996 -y
#exchaincli keys add testval08-4 --recover -m "<menomic>" -y
#exchaincli keys add testval09-5 --recover -m "<menomic>" -y
#exchaincli keys add testval10 --recover -m "<menomic>" --coin-type 996 -y
#exchaincli keys add testval11-4 --recover -m "<menomic>" -y
#exchaincli keys add testval12-3 --recover -m "<menomic>" -y
#exchaincli keys add testval13-5 --recover -m "<menomic>" -y
#exchaincli keys add testval14-3 --recover -m "<menomic>" -y
#exchaincli keys add testval15-4 --recover -m "<menomic>" -y
#exchaincli keys add testval16-4 --recover -m "<menomic>" -y
#exchaincli keys add testval17-3 --recover -m "<menomic>" -y
#exchaincli keys add testval18-3 --recover -m "<menomic>" -y
#exchaincli keys add testval19-4 --recover -m "<menomic>" -y
#exchaincli keys add testval20-5 --recover -m "<menomic>" -y