use cosmwasm_schema::{cw_serde, QueryResponses};
use cw20::Cw20ReceiveMsg;
use cosmwasm_std::Addr;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[cw_serde]
pub struct InstantiateMsg {}

#[cw_serde]
pub enum ExecuteMsg {
    Receive(Cw20ReceiveMsg),
}

#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    #[returns(TokensResp)]
    Tokens{}
}

#[derive(Serialize, Deserialize, Clone, PartialEq, JsonSchema, Debug, Default)]
pub struct TokensResp {
    pub tokens: Vec<Addr>,
}
