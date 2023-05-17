#rm -rf ~/.okbchaincli

#CHAIN_ID="okbchain-67"
#NODE="http://localhost:26657"
#CHAIN_ID="okbchain-197"
#NODE="http://3.113.237.222:26657"

CHAIN_ID="okbchaintest-195"
#NODE="https://okbtesttmrpc.okbchain.org"
NODE=http://35.79.254.36:26657

okbchaincli config chain-id $CHAIN_ID
okbchaincli config output json
okbchaincli config indent true
okbchaincli config trust-node true
okbchaincli config keyring-backend test
okbchaincli config node $NODE


# 4v1r
#okbchaincli keys add --recover val0 -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" --coin-type 996 -y
#okbchaincli keys add --recover val1 -m "palace cube bitter light woman side pave cereal donor bronze twice work" --coin-type 996 -y
#okbchaincli keys add --recover val2 -m "antique onion adult slot sad dizzy sure among cement demise submit scare" --coin-type 996 -y
#okbchaincli keys add --recover val3 -m "lazy cause kite fence gravity regret visa fuel tone clerk motor rent" --coin-type 996 -y


# devnet
#okbchaincli keys add --recover devnet_val0 -m  "junior vague equal mandate asthma bright ridge joke whisper choice old elbow"   -y
#okbchaincli keys add --recover devnet_val1 -m  "ask banner carbon foil portion switch business cart provide shell squirrel feed"    -y
#okbchaincli keys add --recover devnet_val2 -m  "protect eternal vanish rather salute affair suffer coconut address inquiry churn device"    -y
#okbchaincli keys add --recover devnet_val3 -m  "adapt maze wasp sort unit bind song exchange impose muffin title movie"   -y
#okbchaincli keys add --recover devnet_val4 -m  "fame because balcony pyramid menu ginger rack sleep flee cat chief convince"   -y
#okbchaincli keys add --recover devnet_val5 -m  "prize price punch mango mouse weird glass seminar outside search awkward sugar"   -y
#okbchaincli keys add --recover devnet_val6 -m  "screen awkward camera cradle clip armor pretty lounge poem chicken furnace announce"   -y
#okbchaincli keys add --recover devnet_val7 -m  "excess tourist legend auto govern canal runway mango cream light marriage pause"   -y
#okbchaincli keys add --recover devnet_val8 -m  "stone delay soccer cactus energy gravity estate banana fold pull miss hand"   -y
#okbchaincli keys add --recover devnet_val9 -m  "unknown latin quote quote era slam future artist clown always lunar olympic"   -y
#okbchaincli keys add --recover devnet_val10 -m  "lawsuit awake churn birth canyon error boring young dove waste genre all"   -y
#okbchaincli keys add --recover devnet_val11 -m  "guess nothing main blade wealth great height loop quality giggle admit cabbage"   -y
#okbchaincli keys add --recover devnet_val12 -m  "peanut decade melody sample merge clock man citizen treat consider change share"   -y
#okbchaincli keys add --recover devnet_val13 -m  "miracle fun rice tuna spin brown embody oxygen system flock below jelly"   -y
#okbchaincli keys add --recover devnet_val14 -m  "rude bundle rookie swim fruit glimpse door garden figure faculty wealth tired"   -y
#okbchaincli keys add --recover devnet_val15 -m  "mule chunk tent fossil dismiss deny glow purity outside satisfy release chapter"   -y
#okbchaincli keys add --recover devnet_val16 -m  "scene rude adapt tobacco accident cover skill absorb then announce clip miracle"   -y
#okbchaincli keys add --recover devnet_val17 -m  "favorite mask rebel brass notice warrior fuel truck dwarf glide lottery know"   -y
#okbchaincli keys add --recover devnet_val18 -m  "green logic famous cup minor west skill loyal order cost rail reopen"   -y
#okbchaincli keys add --recover devnet_val19 -m  "save quiz input hobby stage obvious dash foil often torch wear sibling"   -y
#okbchaincli keys add --recover devnet_val20 -m  "much type light absorb sound already right connect device fetch burger space"   -y

# devnet 
#okbchaincli keys add --recover devnet_captain -m  "resource eyebrow twelve private raccoon mass renew clutch when monster taste tide" -y
okbchaincli keys add --recover admin17 -m "antique onion adult slot sad dizzy sure among cement demise submit scare" -y
okbchaincli keys add --recover admin18 -m "lazy cause kite fence gravity regret visa fuel tone clerk motor rent" -y

#okbchaincli tx send devnet_captain ex1h0j8x0v9hs4eq6ppgamemfyu4vuvp2sl0q9p3v 1000000okb --fees 0.00002okb --from captain --chain-id $CHAIN_ID -b block -y --node $NODE 
#okbchaincli tx send testnet-val0 ex190227rqaps5nplhg2tg8hww7slvvquzy0qa0l0 10000okb --fees 0.00002okb --from testnet_val0 --chain-id=$CHAIN_ID -b block -y --node=$NODE 
#okbchaincli tx send testnet-val0 ex1fsfwwvl93qv6r56jpu084hxxzn9zphnyxhske5 10000okb --fees 0.00002okb --from testnet_val0 --chain-id=$CHAIN_ID -b block -y --node=$NODE 
