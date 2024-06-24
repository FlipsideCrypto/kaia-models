
{% test missing_decoded_logs(model) %}
SELECT
    l.block_number,
    l._log_id
FROM
    {{ ref('silver__logs') }}
    l
    LEFT JOIN {{ model }}
    d
    ON l.block_number = d.block_number
    AND l._log_id = d._log_id
WHERE
    l.contract_address = LOWER('0xe4f05a66ec68b54a58b17c22107b02e0232cc817') -- WKLAY
    AND l.topics [0] :: STRING = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' -- Transfer
    AND l.block_timestamp BETWEEN DATEADD('hour', -48, SYSDATE())
    AND DATEADD('hour', -6, SYSDATE())
    AND d._log_id IS NULL 
{% endtest %}

{% test missing_gold_decoded_logs(model) %}
SELECT
    l.tx_hash,
    l.event_index
FROM
    {{ ref('core__fact_event_logs') }}
    l
    LEFT JOIN {{ model }}
    d
    ON l.tx_hash = d.tx_hash
    AND l.event_index = d.event_index
WHERE
    l.contract_address = LOWER('0xe4f05a66ec68b54a58b17c22107b02e0232cc817') -- WKLAY
    AND l.topics [0] :: STRING = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' -- Transfer
    AND l.block_timestamp BETWEEN DATEADD('hour', -48, SYSDATE())
    AND DATEADD('hour', -6, SYSDATE())
    AND d.event_index IS NULL 
{% endtest %}
