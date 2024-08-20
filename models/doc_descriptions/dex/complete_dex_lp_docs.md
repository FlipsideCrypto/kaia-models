{% docs kaia_dex_lp_table_doc %}

This table contains details on decentralized exchange (DEX) liquidity pools (LP) on the kaia blockchain, including the tokens, symbols, and decimals within each pool alongside the following protocols: var("DEX_PROTOCOLS")

{% enddocs %}

{% docs kaia_dex_creation_block %}

The block number of when this pool was created.

{% enddocs %}

{% docs kaia_dex_creation_time %}

The block timestamp of when this pool was created.

{% enddocs %}

{% docs kaia_dex_creation_tx %}

The transaction where this pool was created.

{% enddocs %}

{% docs kaia_dex_factory_address %}

The address that created or deployed this pool, where available.

{% enddocs %}

{% docs kaia_dex_lp_decimals %}

The # of decimals for the token included in the liquidity pool, as a JSON object, where available. 

Query example to access the key:value pairing within the object:
SELECT
    DISTINCT pool_address AS unique_pools,
    tokens :token0 :: STRING AS token0,
    symbols: token0 :: STRING AS token0_symbol,
    decimals: token0 :: STRING AS token0_decimal
FROM kaia.defi.dim_dex_liquidity_pools
WHERE token0_decimal = 6
;

{% enddocs %}

{% docs kaia_dex_lp_symbols %}

The symbol for the token included in the liquidity pool, as a JSON object, where available. 

Query example to access the key:value pairing within the object:
SELECT
    DISTINCT pool_address AS unique_pools,
    tokens :token0 :: STRING AS token0,
    symbols: token0 :: STRING AS token0_symbol,
    decimals: token0 :: STRING AS token0_decimal
FROM kaia.defi.dim_dex_liquidity_pools
WHERE token0_symbol = 'WETH'
;

{% enddocs %}

{% docs kaia_dex_lp_tokens %}

The address for the token included in the liquidity pool, as a JSON object. 

Query example to access the key:value pairing within the object:
SELECT
    DISTINCT pool_address AS unique_pools,
    tokens :token0 :: STRING AS token0,
    symbols: token0 :: STRING AS token0_symbol,
    decimals: token0 :: STRING AS token0_decimal
FROM kaia.defi.dim_dex_liquidity_pools
WHERE token0 = '0x98a8345bb9d3dda9d808ca1c9142a28f6b0430e1'
;

{% enddocs %}

{% docs kaia_dex_platform %}

The protocol or platform that the liquidity pool belongs to or swap occurred on. 

{% enddocs %}

{% docs kaia_dex_pool_address %}

The contract address for the liquidity pool. 

{% enddocs %}

{% docs kaia_dex_pool_name %}

The name of the liquidity pool, where available. In some cases, the pool name is a concatenation of symbols or token addresses.

{% enddocs %}

{% docs orders_status %}

Orders can be one of the following statuses:

| status         | description                                                               |
|----------------|---------------------------------------------------------------------------|
| placed         | The order has been placed but has not yet left the warehouse              |
| shipped        | The order has been shipped to the customer and is currently in transit     |
| completed      | The order has been received by the customer                               |
| returned       | The order has been returned by the customer and received at the warehouse |


{% enddocs %}