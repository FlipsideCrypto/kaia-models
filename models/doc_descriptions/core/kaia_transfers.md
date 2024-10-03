{% docs kaia_eth_amount %}

KLAY value transferred.

{% enddocs %}




{% docs kaia_eth_amount_usd %}

KLAY value transferred, in USD.

{% enddocs %}


{% docs kaia_log_id_transfers %}

This is the primary key for this table. This is a concatenation of the transaction hash and the event index at which the transfer event occurred. This field can be used to find more details on the event within the ```fact_event_logs``` table.

{% enddocs %}


{% docs kaia_eth_origin_from %}

The from address at the transaction level. 

{% enddocs %}


{% docs kaia_eth_origin_to %}

The to address at the transaction level. 

{% enddocs %}


{% docs kaia_transfer_amount %}

The decimal transformed amount for this token. Tokens without a decimal adjustment will be nulled out here. 

{% enddocs %}

{% docs kaia_transfer_amount_precise %}

The decimal transformed amount for this token returned as a string to preserve precision. Tokens without a decimal adjustment will be nulled out here.

{% enddocs %}


{% docs kaia_transfer_amount_usd %}

The amount in US dollars for this transfer at the time of the transfer. Tokens without a decimal adjustment or price will be nulled out here. 

{% enddocs %}


{% docs kaia_transfer_contract_address %}

Contract address of the token being transferred.

{% enddocs %}


{% docs kaia_transfer_from_address %}

The sending address of this transfer.

{% enddocs %}


{% docs kaia_transfer_has_decimal %}

Whether or not our contracts model contains the necessary decimal adjustment for this token. 

{% enddocs %}


{% docs kaia_transfer_has_price %}

Whether or not our prices model contains this hourly token price. 

{% enddocs %}


{% docs kaia_transfer_raw_amount %}

The amount of tokens transferred. This value is not decimal adjusted. 

{% enddocs %}

{% docs kaia_transfer_raw_amount_precise %}

The amount of tokens transferred returned as a string to preserve precision. This value is not decimal adjusted.

{% enddocs %}


{% docs kaia_transfer_table_doc %}

This table contains events on the kaia Blockchain with an event name of 'Transfer'. The contract address is the token transferred, and the raw amount field is the amount of tokens transferred. Please note this amount is not decimal adjusted. This table will not contain transfers of native KLAY.

{% enddocs %}


{% docs kaia_transfer_to_address %}

The receiving address of this transfer. This can be a contract address. 

{% enddocs %}


{% docs kaia_transfer_token_price %}

The price, if available, for this token at the transfer time. 

{% enddocs %}


{% docs kaia_transfer_tx_hash %}

Transaction hash is a unique 66-character identifier that is generated when a transaction is executed. This will not be unique in this table as a transaction could include multiple transfer events.

{% enddocs %}


{% docs kaia_fact_token_transfers_table_doc %}

This fact-based table contains emitted event logs for ERC-20 Token Transfers (e.g. `Transfer`: topic_0 = `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`). The contract address is the token transferred, and the raw amount field is the amount of tokens transferred. The values in this table are not decimal adjusted, instead please use `core.dim_contracts` or `core.ez_token_transfers` to reference decimals or decimal adjusted values. This table does not contain ERC-721 and ERC-1155 token transfers, instead please use `nft.ez_nft_transfers`. Additionally, this table does not contain transfers of the chain's native asset, instead please use `core.ez_native_transfers`.

{% enddocs %}

{% docs kaia_ez_token_transfers_table_doc %}

This convenience table contains emitted event logs for ERC-20 Token Transfers (e.g. `Transfer`: topic_0 = `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`), including decimal adjusted values, usd values, and other helpful token metadata where available for each transfer event. The contract address is the token transferred, and the raw amount field is the amount of tokens transferred. Note, this table does not contain ERC-721 and ERC-1155 token transfers, instead please use `nft.ez_nft_transfers`. Additionally, this table does not contain transfers of the chain's native asset, instead please use `core.ez_native_transfers`.

{% enddocs %}

{% docs kaia_ez_native_transfers_table_doc %}

This convenience table contains all transfers for the chain's native asset, sourced from internal traces (`core.fact_traces`), and includes decimal adjusted and usd values where available. The origin addresses correspond to the to and from addresses in the `core.fact_transactions` table. Note, this table does not contain ERC-721 and ERC-1155 token transfers, instead please use `nft.ez_nft_transfers`.

{% enddocs %}