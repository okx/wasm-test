import {SigningCosmWasmClient, GasPrice, parseCoins} from "cosmwasm";
import {OKCSecp256k1Wallet,crypto} from "@okexchain/javascript-sdk"
import { readFileSync } from 'fs';

// This is your rpc endpoint
const rpcEndpoint = "http://127.0.0.1:26657";

// Using a random generated mnemonic
const mnemonic = 'puzzle glide follow cruel say burst deliver wild tragic galaxy lumber offer';

async function main() {
    // Create a wallet
    const privateKey = crypto.getPrivateKeyFromMnemonic(mnemonic)
    console.log(privateKey);
    const signer = await OKCSecp256k1Wallet.fromKey(Buffer.from(privateKey, 'hex'), 'ex')

    const accounts = await signer.getAccounts();
    const captain = accounts[0].address;
    const admin16 = "ex1eutyuqqase3eyvwe92caw8dcx5ly8s544q3hmq";

    // Using
    const client = await SigningCosmWasmClient.connectWithSigner(
        rpcEndpoint,
        signer,
        {gasPrice: GasPrice.fromString('200000000wei'), prefix: 'ex'}
    );

    const wasmCode = readFileSync("../../contract/cw20-base/artifacts/cw20_base.wasm")
    const seq = await client.getSequence(captain);
    console.log(captain, seq);
    const uploadRes = await client.upload(captain, wasmCode, 'auto', "upload")
    //console.log(JSON.stringify(uploadRes));
    console.log(uploadRes);

    const info = await client.instantiate(captain, uploadRes.codeId, {"decimals":10,"initial_balances":[{"address":captain,"amount":"100000000"}],"name":"my test token", "symbol":"MTT"}, "cw20_base", {"amount":parseCoins("20000000000000wei"),"gas":"200000"}, {"funds":parseCoins("1okt"), "admin":captain});
    console.log(info);
    const contract = await client.getContract(info.contractAddress);
    console.log(contract);
    const executeResult = await client.execute(captain, info.contractAddress, {"transfer":{"amount":"10","recipient":admin16}}, {"amount":parseCoins("20000000000000wei"),"gas":"200000"}, "", null);
    console.log(executeResult);
    const captainBalance = await client.queryContractSmart(info.contractAddress, {"balance":{"address":captain}});
    console.log(captainBalance);
    const admin16Balance = await client.queryContractSmart(info.contractAddress, {"balance":{"address":admin16}});
    console.log(admin16Balance);
}

main();