set -o errexit -o nounset -o pipefail

# usage:
#   ./wasm-whitelist all [-c okbchain-64 -i 52.199.88.250]
#   ./wasm-whitelist nobody
#   ./wasm-whitelist "addr1,addr2"

source ./localnet-prepare-okb.sh

DEPOSIT1="frozen sign movie blade hundred engage hour remember analyst island churn jealous"
DEPOSIT2="embrace praise essay heavy rule inner foil mask silk lava mouse still"
DEPOSIT3="witness gospel similar faith runway tape question valley ask stock area reveal"
CAPTAIN_MNEMONIC="resource eyebrow twelve private raccoon mass renew clutch when monster taste tide"
ADMIN0_MNEMONIC="junior vague equal mandate asthma bright ridge joke whisper choice old elbow"
ADMIN1_MNEMONIC="ask banner carbon foil portion switch business cart provide shell squirrel feed"
ADMIN2_MNEMONIC="protect eternal vanish rather salute affair suffer coconut address inquiry churn device"
ADMIN3_MNEMONIC="adapt maze wasp sort unit bind song exchange impose muffin title movie"
ADMIN4_MNEMONIC="fame because balcony pyramid menu ginger rack sleep flee cat chief convince"
ADMIN5_MNEMONIC="prize price punch mango mouse weird glass seminar outside search awkward sugar"
ADMIN6_MNEMONIC="screen awkward camera cradle clip armor pretty lounge poem chicken furnace announce"
ADMIN7_MNEMONIC="excess tourist legend auto govern canal runway mango cream light marriage pause"
ADMIN8_MNEMONIC="stone delay soccer cactus energy gravity estate banana fold pull miss hand"
ADMIN9_MNEMONIC="unknown latin quote quote era slam future artist clown always lunar olympic"
ADMIN10_MNEMONIC="lawsuit awake churn birth canyon error boring young dove waste genre all"
ADMIN11_MNEMONIC="guess nothing main blade wealth great height loop quality giggle admit cabbage"
ADMIN12_MNEMONIC="peanut decade melody sample merge clock man citizen treat consider change share"
ADMIN13_MNEMONIC="miracle fun rice tuna spin brown embody oxygen system flock below jelly"
ADMIN14_MNEMONIC="rude bundle rookie swim fruit glimpse door garden figure faculty wealth tired"
ADMIN15_MNEMONIC="mule chunk tent fossil dismiss deny glow purity outside satisfy release chapter"
ADMIN16_MNEMONIC="scene rude adapt tobacco accident cover skill absorb then announce clip miracle"
ADMIN17_MNEMONIC="favorite mask rebel brass notice warrior fuel truck dwarf glide lottery know"
ADMIN18_MNEMONIC="green logic famous cup minor west skill loyal order cost rail reopen"
ADMIN19_MNEMONIC="save quiz input hobby stage obvious dash foil often torch wear sibling"
ADMIN20_MNEMONIC="much type light absorb sound already right connect device fetch burger space"


OKBCHAIN_DEVNET_VAL_ADMIN_MNEMONIC=(
"${ADMIN0_MNEMONIC}"
"${ADMIN1_MNEMONIC}"
"${ADMIN2_MNEMONIC}"
"${ADMIN3_MNEMONIC}"
"${ADMIN4_MNEMONIC}"
"${ADMIN5_MNEMONIC}"
"${ADMIN6_MNEMONIC}"
"${ADMIN7_MNEMONIC}"
"${ADMIN8_MNEMONIC}"
"${ADMIN9_MNEMONIC}"
"${ADMIN10_MNEMONIC}"
"${ADMIN11_MNEMONIC}"
"${ADMIN12_MNEMONIC}"
"${ADMIN13_MNEMONIC}"
"${ADMIN14_MNEMONIC}"
"${ADMIN15_MNEMONIC}"
"${ADMIN16_MNEMONIC}"
"${ADMIN17_MNEMONIC}"
"${ADMIN18_MNEMONIC}"
"${ADMIN19_MNEMONIC}"
"${ADMIN20_MNEMONIC}"
)

VAL_NODE_NUM=${#OKBCHAIN_DEVNET_VAL_ADMIN_MNEMONIC[@]}


QUERY_EXTRA="--node=$NODE"
TX_EXTRA_UNBLOCKED="--fees 0.01okb --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b async -y"
TX_EXTRA="--fees 0.01okb --gas 3000000 --chain-id=$CHAIN_ID --node $NODE -b block -y"


okbchaincli keys add --recover captain -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" -y
okbchaincli keys add --recover admin17 -m "antique onion adult slot sad dizzy sure among cement demise submit scare" -y
okbchaincli keys add --recover admin18 -m "lazy cause kite fence gravity regret visa fuel tone clerk motor rent" -y


captain=$(okbchaincli keys show captain | jq -r '.eth_address')
admin18=$(okbchaincli keys show admin18 | jq -r '.eth_address')
admin17=$(okbchaincli keys show admin17 | jq -r '.eth_address')
proposal_deposit="100okb"

if [[ $CHAIN_ID == "okbchain-64" ]];
then
  for ((i=0; i<${VAL_NODE_NUM}; i++))
  do
    mnemonic=${OKBCHAIN_DEVNET_VAL_ADMIN_MNEMONIC[i]}
    res=$(okbchaincli keys add --recover val"${i}" -m "$mnemonic" -y)
  done
  val0=$(okbchaincli keys show val0 -a)
  res=$(okbchaincli tx send $val0 $admin17 100okb --from val0 $TX_EXTRA)
  res=$(okbchaincli tx send $val0 $admin18 100okb --from val0 $TX_EXTRA)
  res=$(okbchaincli tx send $val0 $captain 100okb --from val0 $TX_EXTRA)
fi;

# usage:
#   proposal_vote {proposal_id}
proposal_vote() {
  ./vote_okb.sh $1 $CHAIN_ID
#  if [[ $CHAIN_ID == "okbchain-67" ]];
#  then
#    res=$(okbchaincli tx gov vote "$proposal_id" yes --from captain $TX_EXTRA)
#  else
#    echo "gov voting, please wait..."
#    for ((i=0; i<${VAL_NODE_NUM}; i++))
#    do
#      if [[ ${i} -lt $((${VAL_NODE_NUM}*2/3)) ]];
#      then
#        res=$(okbchaincli tx gov vote "$1" yes --from val"$i" $TX_EXTRA_UNBLOCKED)
#      else
#        res=$(okbchaincli tx gov vote "$1" yes --from val"$i" $TX_EXTRA)
#        proposal_status=$(okbchaincli query gov proposal "$1" $QUERY_EXTRA | jq ".proposal_status" | sed 's/\"//g')
#        echo "status: $proposal_status"
#        if [[ $proposal_status == "Passed" ]];
#        then
#          break
#        fi;
#      fi;
#    done
#  fi;
}

#####################################################
########    update deployment whitelist     #########
#####################################################
echo "## update wasm code deployment whitelist"
res=$(okbchaincli tx gov submit-proposal update-wasm-deployment-whitelist $captain --deposit ${proposal_deposit} --title "test title" --description "test description" --from captain $TX_EXTRA)
proposal_id=$(echo "$res" | jq '.logs[0].events[1].attributes[1].value' | sed 's/\"//g')
echo "proposal_id: $proposal_id"
proposal_vote "$proposal_id"

echo "all cases succeed~"
