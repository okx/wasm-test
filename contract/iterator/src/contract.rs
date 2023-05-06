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
    let vector = vec![
        "0x014816AA63F9E6324240B596d0119c3ef544389F",
        "0x06a599faa50644Fb39A43448CD1063dcd9d28783",
        "0x17031a9Efc49dc6c805855AFE67BF7f7cDb65204",
        "0x1A6Ca13FFD7CDdb0dD11b9Ef691828ef54ca55c1",
        "0x1BaaA4301268D67BbA3e7a8BC6Ca62992695648D",
        "0x1f3FC034C0616582dC5BaC329Ba3AC038176E68E",
        "0x26B800667d34A870C5cF054eF299B7d6A60cabA6",
        "0x4ce08FfC090f5c54013c62efe30D62E6578E738D",
        "0x4D744462d36269af28ec86446946A2E7dC19818c",
        "0x574CFB6397e62F6C725B93587d069C0dFE787F33",
        "0x5A8D648DEE57b2fc90D98DC17fa887159b69638b",
        "0x62792bD9bb1B0ee9B0C001BEDDAd77472dB15471",
        "0x6BF3671E9401fe270cE3bAdBC6B997a88c40461d",
        "0x71efC79707B59A887bDd37CaCB899048DD276862",
        "0x75a8Fe4b9929769ee37a61612B486Cdf343f2144",
        "0x8651e94972a56e69F3C0897d9E8faCbDAEb98386",
        "0x9536354AE32852A7E7C4BFe7415b104016d5Fb04",
        "0x97B05e6C5026D5480c4B6576A8699866eb58003b",
        "0x9866e0D7E06b447A23a96cC4f25Bc0D686A5B555",
        "0xae1B7Aae07cb4f40b967f2d94dE5C3758c3d5C45",
        "0xaEf59EEcD3F1c042F7fbB6e0B0E837E0aF8E13A6",
        "0xA55d9ef16Af921b70Fed1421C1D298Ca5A3a18F1",
        "0xADf040519FE24bA9Df6670599B2dE7FD6049772f",
        "0xB26C63498bBa95589704F3d5A1fE2DF763C8B7a4",
        "0xc461EDEEeC176Caeb16eA54a0480CDCD4aBf6728",
        "0xc97b81B8a38b9146010Df85f1Ac714aFE1554343",
        "0xCc09DE85A896cA0B44d589CD06084eE4a538CaFF",
        "0xeed366Ecc8fdF12192012D36094bE18D176029Ff",
        "0xf6Aab105CB9e66e03CAD2c2F3f8558242593385c",
        "0xf76F95DCE4ab59974540AE063FFbEfd254BeBfcD"
        ];

    for i in &vector {
        let addr: Addr = deps.api.addr_validate(&i.to_string())?;
        BALANCES.update(
            deps.storage,
            &addr,
            |balance: Option<Uint128>| -> StdResult<_> {
                Ok(balance.unwrap_or_default().checked_sub(Uint128::zero())?)
            },
        )?;
    }
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
        ExecuteMsg::Add { spender } => try_add(deps,spender)
    }
}

pub fn try_add(deps: DepsMut,spender:String) -> Result<Response, ContractError> {
    let spender: Addr = deps.api.addr_validate(spender.as_str())?;

    BALANCES.update(
        deps.storage,
        &spender,
        |balance: Option<Uint128>| -> StdResult<_> {
            Ok(balance.unwrap_or_default().checked_sub(Uint128::zero())?)
        },
    )?;
    Ok(Response::new())
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetAddress {ascending, start, end, index} => to_binary(&query_address(deps, ascending, start, end, index)?),
    }
}

fn query_address(deps: Deps, ascending : bool, start : String, end : String, index: i32) -> StdResult<String> {
    let mut order :Order = cosmwasm_std::Order::Descending;
    if ascending {
        order = cosmwasm_std::Order::Ascending;
    }
    
    let mut min :Option<Bound<&Addr>> = None;
    let mut max :Option<Bound<&Addr>> = None;
    let startIndex: Addr;
    let endIndex: Addr;
    if start.len() != 0 {
        startIndex = deps.api.addr_validate(&start)?;
        min = Some(Bound::exclusive(&startIndex));
    }
    if end.len() != 0{
        endIndex = deps.api.addr_validate(&end)?;
        max = Some(Bound::exclusive(&endIndex));
    }
    
    let data: Vec<(Addr, Uint128)> = BALANCES
            .range(deps.storage, min, max, order)
            .collect::<StdResult<Vec<_>>>()?;
    let mut i = 0;
    let mut address: String = "".to_string();
    for (owner, allowance) in &data {
        if i == index{
            address = (&owner).to_string();
            break;
        }
        i = i + 1;
    }

    let info : Option<String> = Some(address);
    Ok(info.unwrap())
}