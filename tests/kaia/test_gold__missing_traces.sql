-- depends_on: {{ ref('test_gold__transactions_full') }}
{{ gold_missing_txs(
    ref("test_gold__traces_full"),
    "block_timestamp >= '2024-05-31' AND block_timestamp <= DATEADD(hour, -3, CURRENT_TIMESTAMP)"
) }}
