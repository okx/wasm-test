use cosmwasm_std::{DepsMut, Env, Reply, Response, entry_point, SubMsgExecutionResponse, Event, Binary, ContractResult};
use crate::error::ContractError;

pub const REPLY_ID_ERROR: u64 = 0;
pub const REPLY_ID_SUCCESS: u64 = 1;

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn reply(deps: DepsMut, _env: Env, reply: Reply) -> Result<Response, ContractError> {

    match reply.id {
        REPLY_ID_ERROR => Err(ContractError::ContractERC20Err {
                    addr: reply.id.to_string(),
        }),
        REPLY_ID_SUCCESS => match reply.result {
            ContractResult::Ok(_) => reply_success(reply),
            ContractResult::Err(err) => {
                Ok(Response::new()
                    .add_attribute("reply_success", reply.id.to_string()))
            }
        },
        _ => Err(ContractError::UnknownReplyId { id: reply.id }),
    }
    // match reply.id {
    //     0 =>  Err(ContractError::ContractERC20Err {
    //         addr: reply.id.to_string(),
    //     }),
    //     1 => reply_success(reply),
    //     _ =>  Err(ContractError::ContractERC20Err {
    //         addr: reply.id.to_string(),
    //     }),
    // }
}

fn reply_success(reply:Reply) -> Result<Response, ContractError> {

    let result: SubMsgExecutionResponse = reply.result.unwrap();
    let mut events : Vec<Event> = vec![];
    events.extend(result.events.into_iter());
    match result.data {
        Some(data) => { Ok(Response::new()
            .add_attribute("reply_success", reply.id.to_string())
            .set_data(data))},
        _ =>{Ok(Response::new()
            .add_attribute("reply_success", reply.id.to_string()))},
    }

}