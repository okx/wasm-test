import { SigningCosmWasmClient, Secp256k1HdWallet, coin, parseCoins } from "cosmwasm";
import { stringToPath } from "@cosmjs/crypto";
import { readFileSync } from 'fs';

//import { HdPath, Slip10RawIndex } from "@cosmjs/crypto";

// This is your rpc endpoint
const rpcEndpoint = "http://localhost:26657";

// Using a random generated mnemonic
const mnemonic = "palace cube bitter light woman side pave cereal donor bronze twice work";

async function main() {
    // Create a wallet
    //const path = stringToPath("m/44'/118'/0'/0/0")
    // const path = [
    //   Slip10RawIndex.hardened(44),
    //   Slip10RawIndex.hardened(60),
    //   Slip10RawIndex.hardened(0),
    //   Slip10RawIndex.normal(0),
    //   Slip10RawIndex.normal(0),
    // ];
    const path = stringToPath("m/44'/118'/0'/0/0");
    const wallet = await Secp256k1HdWallet.fromMnemonic(mnemonic, {hdPaths:[path], "prefix":"ex"});
    console.log(wallet.mnemonic);
    const accs = await wallet.getAccounts();
    const admin16 = accs[0].address;
    const captain = "ex1h0j8x0v9hs4eq6ppgamemfyu4vuvp2sl0q9p3v";

    // Using
    const client = await SigningCosmWasmClient.connectWithSigner(
        rpcEndpoint,
        wallet,
    );
    //console.log(client);
    const wasmBytecode = readFileSync('../../contract/cw20-base/artifacts/cw20_base.wasm');
    const uploadRes = await client.upload(admin16, wasmBytecode, {"amount":parseCoins("2000000000000000wei"),"gas":"20000000"});
    console.log(uploadRes.codeId);
    const codes = await client.getCodes();
    console.log(codes);

    const info = await client.instantiate(admin16, uploadRes.codeId, {"decimals":10,"initial_balances":[{"address":admin16,"amount":"100000000"}],"name":"my test token", "symbol":"MTT"}, "cw20_base", {"amount":parseCoins("20000000000000wei"),"gas":"200000"}, {"funds":parseCoins("1okt"), "admin":captain});
    console.log(info);
    const contract = await client.getContract(info.contractAddress);
    console.log(contract);
    const executeResult = await client.execute(admin16, info.contractAddress, {"transfer":{"amount":"10","recipient":captain}}, {"amount":parseCoins("20000000000000wei"),"gas":"200000"}, "", null);
    console.log(executeResult);
    const admin16Balance = await client.queryContractSmart(info.contractAddress, {"balance":{"address":admin16}});
    console.log(admin16Balance);
    const captainBalance = await client.queryContractSmart(info.contractAddress, {"balance":{"address":captain}});
    console.log(captainBalance);
}

main();