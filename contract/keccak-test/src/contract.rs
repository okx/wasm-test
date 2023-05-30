#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{to_binary, Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult};

use sha3::{Digest, Keccak256};

use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg};

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    _msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    Ok(Response::new())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::Test { mode, count, data } => test(deps, mode, count, data),
    }
}

pub fn test(deps: DepsMut, mode: i32, count: i32, data: String) -> Result<Response, ContractError> {
    if mode == 0 {
        return try_test_nil(deps, count, data);
    }

    if mode == 1 {
        return try_test_contract(deps, count, data);
    }

    if mode == 2 {
        return try_test_vm(deps, count, data);
    }

    return try_test_go(deps, count, data);
}

pub fn try_test_vm(
    deps: DepsMut,
    count: i32,
    inputdata: String,
) -> Result<Response, ContractError> {
    // let data  = hex::decode(inputdata).to_owned();
    let data: &str = &inputdata;
    let mut number = 0;
    let mut temp: String = "".to_string();
    while number != count {
        number += 1;
        let result = deps.api.keccak256(data.as_bytes());
        if number == 1 {
            temp = hex::encode(result.unwrap());
        }
    }
    Ok(Response::new()
        .add_attribute("try_test_vm", temp)
        .add_attribute("number", number.to_string()))
}

pub fn try_test_contract(
    deps: DepsMut,
    count: i32,
    inputdata: String,
) -> Result<Response, ContractError> {
    let data: &str = &inputdata;
    let mut number = 0;
    let mut temp: String = "".to_string();
    while number != count {
        number += 1;
        let hash = Keccak256::digest(data.as_bytes());
        if number == 1 {
            temp = hex::encode(hash);
        }
    }

    Ok(Response::new()
        .add_attribute("try_test_contract", temp)
        .add_attribute("number", number.to_string()))
}

pub fn try_test_nil(
    deps: DepsMut,
    count: i32,
    inputdata: String,
) -> Result<Response, ContractError> {
    let data = hex::decode(inputdata).to_owned();
    let temp = hex::encode(data.unwrap());
    let mut number = 0;
    while number != count {
        number += 1;
    }

    Ok(Response::new()
        .add_attribute("try_test_nil", temp)
        .add_attribute("number", number.to_string()))
}

pub fn try_test_go(
    deps: DepsMut,
    count: i32,
    inputdata: String,
) -> Result<Response, ContractError> {
    // let data  = hex::decode(inputdata).to_owned();

    let mut number = 0;
    let mut temp: String = "".to_string();
    while number != count {
        number += 1;
        let result = deps.api.addr_canonicalize(&inputdata);
        if number == 1 {
            temp = result.unwrap().to_string();
        }
    }

    Ok(Response::new()
        .add_attribute("try_test_go", temp)
        .add_attribute("number", number.to_string()))
}

pub fn try_verify(deps: DepsMut) -> Result<Response, ContractError> {
    let hash =
        hex::decode("1ff5c235b3c317d054b80b4bf0a8038bd727d180872d2491a7edef4f949c4135").to_owned();
    let signature = hex::decode("b9299dab50b3cddcaecd64b29bfbd5cd30fac1a1adea1b359a13c4e5171492a6573059c66d894684488f92e7ce1f91b158ca57b0235485625b576a3b98c480ac").to_owned();
    let pubkey= hex::decode("041d4c015b00cbd914e280b871d3c6ae2a047ca650d3ecea4b5246bb3036d4d74960b7feb09068164d2b82f1c7df9e95839b29ae38e90d60578b2318a54e108cf8").to_owned();

    let result = deps.api.secp256k1_verify(
        &hash.to_owned().unwrap(),
        &signature.to_owned().unwrap(),
        &pubkey.to_owned().unwrap(),
    );

    Ok(Response::new().add_attribute("try_verify", result.unwrap().to_string()))
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetCounter {} => to_binary(&query_count(deps)?),
    }
}

fn query_count(deps: Deps) -> StdResult<i32> {
    Ok(1)
}
