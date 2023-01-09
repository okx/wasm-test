import { fromHex, toHex } from "@cosmjs/encoding";
import { keccak256, Secp256k1 } from "@cosmjs/crypto";

const privkey = fromHex("8ff3ca2d9985c3a52b459e2f6e7822b23e1af845961e22128d5f372fb9aa5f17");
const keypair = await Secp256k1.makeKeypair(privkey);
console.log(toHex(keypair.pubkey)); //04917cddc74df72174b992e532d85cbb44fb730a1fd77983aaaa92fcd4c99e3e9398a3cc8e3b10cf2cea93411ea91236eae556cf3a5f5e53ff4f7144da810d5c4f
const compressed = Secp256k1.compressPubkey(keypair.pubkey);
console.log(toHex(compressed)); //03917cddc74df72174b992e532d85cbb44fb730a1fd77983aaaa92fcd4c99e3e93
const address = `0x${toHex(keccak256(keypair.pubkey.slice(1)).slice(-20))}`;
console.log(address); //0xbbe4733d85bc2b90682147779da49cab38c0aa1f
