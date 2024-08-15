{% docs ez_dex_swaps_table_doc %}

This table currently contains swap events from the ```fact_event_logs``` table for DRAGONSWAP, KAIASWAP, KLAYSWAP, AND NEOPIN. along with other helpful columns including an amount USD where possible.
Note: A rule has been put in place to null out the amount_USD if that number is too divergent between amount_in_USD and amount_out_usd. This can happen for swaps of less liquid tokens during very high fluctuation of price.

{% enddocs %}

{% docs kaia_dex_swaps_amount_in %}

The amount of tokens put into the swap.

{% enddocs %}

{% docs kaia_dex_swaps_amount_in_unadj %}

The non-decimal adjusted amount of tokens put into the swap.

{% enddocs %}

{% docs kaia_dex_swaps_amount_in_usd %}

The value of the swapped tokens in USD at the time of the transaction, where available. If there is a variance of 75% or greater in USD swap values or one side of the swap's USD value is NULL, then both amount_in_usd and amount_out_usd will be set to NULL. This avoids falsely overstating USD swap volumes for low-liquidity token pairings or incorrectly reported prices. To get USD values in these scenarios anyway, please re-join the `price.ez_prices_hourly` table. Note, this logic does not apply for the chain's Native asset.

{% enddocs %}

{% docs kaia_dex_swaps_amount_out %}

The value of the swapped tokens in USD at the time of the transaction, where available. If there is a variance of 75% or greater in USD swap values or one side of the swap's USD value is NULL, then both amount_in_usd and amount_out_usd will be set to NULL. This avoids falsely overstating USD swap volumes for low-liquidity token pairings or incorrectly reported prices. To get USD values in these scenarios anyway, please re-join the `price.ez_prices_hourly` table. Note, this logic does not apply for the chain's Native asset.

{% enddocs %}

{% docs kaia_dex_swaps_amount_out_unadj %}

The non-decimal adjusted amount of tokens taken out of or received from the swap.

{% enddocs %}

{% docs kaia_dex_swaps_amount_out_usd %}

The amount of tokens taken out of or received from the swap converted to USD using the price of the token.

{% enddocs %}

{% docs kaia_dex_swaps_sender %}

The Router is the Sender in the swap function. 

{% enddocs %}

{% docs kaia_dex_swaps_symbol_in %}

The symbol of the token sent for swap.

{% enddocs %}

{% docs kaia_dex_swaps_symbol_out %}

The symbol of the token being swapped to.

{% enddocs %}

{% docs kaia_dex_swaps_token_in %}

The address of the token sent for swap.

{% enddocs %}

{% docs kaia_dex_swaps_token_out %}

The address of the token being swapped to.

{% enddocs %}

{% docs kaia_dex_swaps_tx_to %}

The tx_to is the address who receives the swapped token. This corresponds to the "to" field in the swap function.

{% enddocs %}

{% docs kaia_dex_token0 %}

Token 0 is the first token in the pair, and will show up first within the event logs for relevant transactions. 

{% enddocs %}

{% docs kaia_dex_token1 %}

Token 1 is the second token in the pair, and will show up second within the event logs for relevant transactions. 

{% enddocs %}

{% docs kaia_dex_tokens %}

This field contains the tokens within the liquidity pool as a JSON objects.

{% enddocs %}