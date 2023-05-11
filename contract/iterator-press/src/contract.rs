#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{to_binary, Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult,Uint256};
use cw_storage_plus::{Map};
use cosmwasm_std::{Addr, Uint128};
use cosmwasm_std::Order::Ascending;
use cosmwasm_std::Order::Descending;
use cosmwasm_std::Order;
use cw_storage_plus::Bound;

use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg};

pub const BALANCES: Map<&Addr, Uint128> = Map::new("blance");

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
        ExecuteMsg::Add { spender } => try_add(deps,spender),
        ExecuteMsg::Press { ascending } => try_press(deps, ascending)
    }
}

pub fn try_add(deps: DepsMut,spender:Box<[String]>) -> Result<Response, ContractError> {
    for i in spender.iter() {
        let spender: Addr = deps.api.addr_validate(i.as_str())?;

        BALANCES.update(
            deps.storage,
            &spender,
            |balance: Option<Uint128>| -> StdResult<_> {
                Ok(balance.unwrap_or_default().checked_sub(Uint128::zero())?)
            },
        )?;
    }
    Ok(Response::new())
}

pub fn try_press(deps: DepsMut, ascending : bool) -> Result<Response, ContractError> {
    let mut order :Order = cosmwasm_std::Order::Descending;
    if ascending {
        order = cosmwasm_std::Order::Ascending;
    }
    
    let data: Vec<(Addr, Uint128)> = BALANCES
            .range(deps.storage, None, None, order)
            .collect::<StdResult<Vec<_>>>()?;
    let mut i: i32 = 0;
    for (owner, allowance) in &data {
        i = i + 1;
    }
    Ok(Response::new())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetTotal {} => to_binary(&query_total(deps)?),
    }
}

fn query_total(deps: Deps) -> StdResult<i32> {
    let data: Vec<(Addr, Uint128)> = BALANCES
            .range(deps.storage, None, None, cosmwasm_std::Order::Ascending)
            .collect::<StdResult<Vec<_>>>()?;
    let mut i: i32 = 0;
    let mut address: String = "".to_string();
    for (owner, allowance) in &data {
        i = i + 1;
    }

    let info : Option<i32> = Some(i);
    Ok(info.unwrap())
}