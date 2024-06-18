-- depends_on: {{ ref('test_gold__transactions_recent') }}
{{ gold_recent_missing_txs(
    ref("test_gold__traces_recent"),
    "block_timestamp <= DATEADD(hour, -3, CURRENT_TIMESTAMP)"
) }}