-- depends_on: {{ ref('test_gold__blocks_full') }}
{{ tx_gaps(ref("test_gold__transactions_full")) }}
