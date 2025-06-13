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

{% docs kaia_transfer_to_address %}

The receiving address of this transfer. This can be a contract address. 

{% enddocs %}


{% docs kaia_transfer_token_price %}

The price, if available, for this token at the transfer time. 

{% enddocs %}


{% docs kaia_transfer_tx_hash %}

Transaction hash is a unique 66-character identifier that is generated when a transaction is executed. This will not be unique in this table as a transaction could include multiple transfer events.

{% enddocs %}