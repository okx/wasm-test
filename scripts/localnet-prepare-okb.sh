rm -rf ~/.okbchaincli

CHAIN_ID="okbchain-67"
NODE="http://localhost:26657"

okbchaincli config chain-id $CHAIN_ID
okbchaincli config output json
okbchaincli config indent true
okbchaincli config trust-node true
okbchaincli config keyring-backend test
okbchaincli config node $NODE


# 4v1r
okbchaincli keys add --recover val0 -m "puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer" --coin-type 996 -y
okbchaincli keys add --recover val1 -m "palace cube bitter light woman side pave cereal donor bronze twice work" --coin-type 996 -y
okbchaincli keys add --recover val2 -m "antique onion adult slot sad dizzy sure among cement demise submit scare" --coin-type 996 -y
okbchaincli keys add --recover val3 -m "lazy cause kite fence gravity regret visa fuel tone clerk motor rent" --coin-type 996 -y


# devnet
okbchaincli keys add --recover devnet_val0 -m  "junior vague equal mandate asthma bright ridge joke whisper choice old elbow" --coin-type 996 -y
okbchaincli keys add --recover devnet_val1 -m  "ask banner carbon foil portion switch business cart provide shell squirrel feed"  --coin-type 996 -y
okbchaincli keys add --recover devnet_val2 -m  "protect eternal vanish rather salute affair suffer coconut address inquiry churn device"  --coin-type 996 -y
okbchaincli keys add --recover devnet_val3 -m  "adapt maze wasp sort unit bind song exchange impose muffin title movie" --coin-type 996 -y
okbchaincli keys add --recover devnet_val4 -m  "fame because balcony pyramid menu ginger rack sleep flee cat chief convince" --coin-type 996 -y
okbchaincli keys add --recover devnet_val5 -m  "prize price punch mango mouse weird glass seminar outside search awkward sugar" --coin-type 996 -y
okbchaincli keys add --recover devnet_val6 -m  "screen awkward camera cradle clip armor pretty lounge poem chicken furnace announce" --coin-type 996 -y
okbchaincli keys add --recover devnet_val7 -m  "excess tourist legend auto govern canal runway mango cream light marriage pause" --coin-type 996 -y
okbchaincli keys add --recover devnet_val8 -m  "stone delay soccer cactus energy gravity estate banana fold pull miss hand" --coin-type 996 -y
okbchaincli keys add --recover devnet_val9 -m  "unknown latin quote quote era slam future artist clown always lunar olympic" --coin-type 996 -y
okbchaincli keys add --recover devnet_val10 -m  "lawsuit awake churn birth canyon error boring young dove waste genre all" --coin-type 996 -y
okbchaincli keys add --recover devnet_val11 -m  "guess nothing main blade wealth great height loop quality giggle admit cabbage" --coin-type 996 -y
okbchaincli keys add --recover devnet_val12 -m  "peanut decade melody sample merge clock man citizen treat consider change share" --coin-type 996 -y
okbchaincli keys add --recover devnet_val13 -m  "miracle fun rice tuna spin brown embody oxygen system flock below jelly" --coin-type 996 -y
okbchaincli keys add --recover devnet_val14 -m  "rude bundle rookie swim fruit glimpse door garden figure faculty wealth tired" --coin-type 996 -y
okbchaincli keys add --recover devnet_val15 -m  "mule chunk tent fossil dismiss deny glow purity outside satisfy release chapter" --coin-type 996 -y
okbchaincli keys add --recover devnet_val16 -m  "scene rude adapt tobacco accident cover skill absorb then announce clip miracle" --coin-type 996 -y
okbchaincli keys add --recover devnet_val17 -m  "favorite mask rebel brass notice warrior fuel truck dwarf glide lottery know" --coin-type 996 -y
okbchaincli keys add --recover devnet_val18 -m  "green logic famous cup minor west skill loyal order cost rail reopen" --coin-type 996 -y
okbchaincli keys add --recover devnet_val19 -m  "save quiz input hobby stage obvious dash foil often torch wear sibling" --coin-type 996 -y
okbchaincli keys add --recover devnet_val20 -m  "much type light absorb sound already right connect device fetch burger space" --coin-type 996 -y
