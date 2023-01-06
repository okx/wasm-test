#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult, WasmMsg, to_binary};
// use cw2::set_contract_version;
use cw20::{Cw20ReceiveMsg, Cw20ExecuteMsg::IncreaseAllowance};

use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg, TokensResp};
use crate::state::TOKENS;

/*
// version info for migration info
const CONTRACT_NAME: &str = "crates.io:cw20-pot";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");
*/

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    _deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    _msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    Ok(Response::new())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::Receive(msg) => execute_receive(deps, env, info, msg),
    }
}

pub fn execute_receive(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    wrapper: Cw20ReceiveMsg,
) -> Result<Response, ContractError> {
    // info.sender is the address of the cw20 contract (that re-sent this message).
    // wrapper.sender is the address of the user that requested the cw20 contract to send this.
    // This cannot be fully trusted (the cw20 contract can fake it), so only use it for actions
    // in the address's favor (like paying/bonding tokens, not withdrawls)
    // let msg: ReceiveMsg = from_slice(&wrapper.msg)?;
    // let balance = Balance::Cw20(Cw20CoinVerified {
    //     address: info.sender,
    //     amount: wrapper.amount,
    // });

    let sender = wrapper.sender.clone();
    let msg = to_binary(&IncreaseAllowance {
        spender: sender.clone(),
        amount: wrapper.amount,
        expires: None,
    })?;
    if let Some(mut data) = TOKENS.may_load(deps.storage)? {
        let tokens = &mut data.tokens;
        if !tokens.contains(&info.sender) {
            tokens.push(info.sender.clone());
            tokens.sort();
            TOKENS.save(deps.storage, &data)?;
        }
    } else {
        let tokens = vec![info.sender.clone()];
        TOKENS.save(deps.storage, &TokensResp { tokens })?;
    }

    let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_message(
            WasmMsg::Execute {
                contract_addr: info.sender.into_string(),
                msg,
                funds: vec![],
            }
        );
    Ok(res)
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::Tokens{} => to_binary(&query::tokens(deps)?),
    }
    //unimplemented!()
}

mod query {
    use super::*;
    pub fn tokens(deps: Deps) -> StdResult<TokensResp> {
        Ok(TOKENS.may_load(deps.storage)?.unwrap_or_default())
    }
}

#[cfg(test)]
mod tests {}
