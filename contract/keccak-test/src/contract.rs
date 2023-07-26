#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{to_binary, Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult};

use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg};

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    _: DepsMut,
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
        ExecuteMsg::Test {} => test(deps),
    }
}

pub fn test(deps: DepsMut) -> Result<Response, ContractError> {
    return try_test_vm(deps);
}

pub fn try_test_vm(deps: DepsMut) -> Result<Response, ContractError> {
    let data: &str = "123";
    let number = 0;
    let temp: String = "123".to_string();
    let _ = deps.api.keccak256(data.as_bytes());
    Ok(Response::new()
        .add_attribute("try_test_vm", temp)
        .add_attribute("number", number.to_string()))
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetCounter {} => to_binary(&query_count(deps)?),
    }
}

fn query_count(_: Deps) -> StdResult<i32> {
    Ok(1)
}
