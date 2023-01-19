use cw_storage_plus::Item;
use crate::msg::TokensResp;

pub const TOKENS: Item<TokensResp> = Item::new("tokens");