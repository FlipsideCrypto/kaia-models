{% test missing_decoded_logs(model) %}
SELECT
    l.block_number,
    l.CONCAT(tx_hash :: STRING, '-', event_index :: STRING) AS _log_id
FROM
    {{ ref('core__fact_event_logs') }}
    l
    LEFT JOIN {{ model }}
    d
    ON l.block_number = d.block_number
    AND CONCAT(
        l.tx_hash,
        '-',
        l.event_index
    ) = d._log_id
WHERE
    LOWER('0x19aac5f612f524b754ca7e7c41cbfa2e981a4432') -- WKLAY
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
    l.contract_address = LOWER('0x19aac5f612f524b754ca7e7c41cbfa2e981a4432') -- WKLAY
    AND l.topics [0] :: STRING = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef' -- Transfer
    AND l.block_timestamp BETWEEN DATEADD('hour', -48, SYSDATE())
    AND DATEADD('hour', -6, SYSDATE())
    AND d.event_index IS NULL 
{% endtest %}