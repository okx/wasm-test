#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult, WasmMsg, to_binary, SubMsg, Reply}; //SubMsgResponse, SubMsgResult
// use cw2::set_contract_version;
use cw20::{Cw20ReceiveMsg, Cw20ExecuteMsg::IncreaseAllowance};
use cw_utils::Expiration;

use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg, TokensResp};
use crate::state::TOKENS;

const REPLY_ID: u64 = 1;

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
    env: Env,
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
    let valid_msg = IncreaseAllowance {
        spender: sender.clone(),
        amount: wrapper.amount,
        expires: None,
    }; 
    let invalid_msg = IncreaseAllowance {
        spender: env.contract.address.into_string(),
        amount: wrapper.amount,
        expires: Some(Expiration::AtHeight(0)),
    }; 

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
    
    let amount = wrapper.amount.u128();
    if amount == 1 {
        // expected reply
        let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_submessage(SubMsg::reply_on_success(WasmMsg::Execute {
            contract_addr: info.sender.into_string(),
            msg: to_binary(&valid_msg)?,
            funds: vec![],
        }, REPLY_ID));
        return Ok(res);
    } else if amount == 2 {
        // expected no reply
        let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_submessage(SubMsg::reply_on_success(WasmMsg::Execute {
            contract_addr: info.sender.into_string(),
            msg: to_binary(&invalid_msg)?,
            funds: vec![],
        }, REPLY_ID));
        return Ok(res);
    } else if amount == 3 {
        // expected no reply
        let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_submessage(SubMsg::reply_on_error(WasmMsg::Execute {
            contract_addr: info.sender.into_string(),
            msg: to_binary(&valid_msg)?,
            funds: vec![],
        }, REPLY_ID));
        return Ok(res);
    } else if amount == 4 {
        // expected reply
        let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_submessage(SubMsg::reply_on_error(WasmMsg::Execute {
            contract_addr: info.sender.into_string(),
            msg: to_binary(&invalid_msg)?,
            funds: vec![],
        }, REPLY_ID));
        return Ok(res);
    } else if amount == 5 {
        // expected reply
        let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_submessage(SubMsg::reply_always(WasmMsg::Execute {
            contract_addr: info.sender.into_string(),
            msg: to_binary(&valid_msg)?,
            funds: vec![],
        }, REPLY_ID));
        return Ok(res);
    } else if amount == 6 {
        // expected reply
        let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_submessage(SubMsg::reply_always(WasmMsg::Execute {
            contract_addr: info.sender.into_string(),
            msg: to_binary(&invalid_msg)?,
            funds: vec![],
        }, REPLY_ID));
        return Ok(res);
    };

    let res = Response::new()
        .add_attribute("action", "receive")
        .add_attribute("sender", &sender)
        .add_attribute("amount", wrapper.amount)
        .add_message(
            WasmMsg::Execute {
                contract_addr: info.sender.into_string(),
                msg: to_binary(&valid_msg)?,
                funds: vec![],
            }
        );
    Ok(res)
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn reply(_deps: DepsMut, env: Env, msg: Reply) -> Result<Response, ContractError> {
    if msg.id == REPLY_ID {
        return Ok(Response::new()
        .add_attribute("action", "reply")
        .add_attribute("messageID", format!("{}", REPLY_ID))
        .add_attribute("height", format!("{}", env.block.height))
        .add_attribute("timestamp", format!("{}", env.block.time.seconds())));
    };

    Ok(Response::new())
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
