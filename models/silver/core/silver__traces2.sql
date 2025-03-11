-- depends_on: {{ ref('bronze__streamline_traces') }}
{{ config (
    materialized = "incremental",
    incremental_strategy = 'delete+insert',
    unique_key = "block_number",
    cluster_by = ['modified_timestamp::DATE','partition_key'],
    full_refresh = false,
    tags = ['non_realtime']
) }}

WITH bronze_traces AS (

    SELECT
        block_number,
        partition_key,
        VALUE :array_index :: INT AS tx_position,
        DATA :result AS full_traces,
        _inserted_timestamp
    {% if is_incremental() and not var('full_reload_mode', false) %}
    FROM
        {{ ref('bronze__streamline_traces') }}
        WHERE
            _inserted_timestamp >= (
                SELECT
                    MAX(_inserted_timestamp) _inserted_timestamp
                FROM
                    {{ this }}
            )
            AND DATA :result IS NOT NULL
        and block_number > 160000000
        and partition_key > 160000000

    {% elif is_incremental() and var('full_reload_mode', false) and not var('initial_load', false) %}
    FROM
        {{ ref('bronze__streamline_fr_traces') }}
        WHERE
        partition_key BETWEEN (
            SELECT
                MAX(partition_key)
            FROM
                {{ this }}
            WHERE
                partition_key < 80000000
        ) - 1000000
        AND (
            SELECT
                MAX(partition_key)
            FROM
                {{ this }}
            WHERE
                partition_key < 80000000
        ) + 4000000
        AND DATA :result IS NOT NULL

    {% elif var('initial_load', false) %}
    FROM
        {{ ref('bronze__streamline_fr_traces') }}
        WHERE 
            DATA :result IS NOT NULL
            AND partition_key BETWEEN 0 AND 5000000

    {% else %}
        {{ ref('bronze__streamline_fr_traces') }}
        WHERE partition_key <= 149500000
    {% endif %}

    qualify(ROW_NUMBER() over (PARTITION BY block_number, tx_position
    ORDER BY
        _inserted_timestamp DESC)) = 1
),
flatten_traces AS (
    SELECT
        block_number,
        tx_position,
        partition_key,
        IFF(
            path IN (
                'result',
                'result.value',
                'result.type',
                'result.to',
                'result.input',
                'result.gasUsed',
                'result.gas',
                'result.from',
                'result.output',
                'result.error',
                'result.revertReason',
                'result.time',
                'gasUsed',
                'gas',
                'type',
                'to',
                'from',
                'value',
                'input',
                'error',
                'output',
                'time',
                'revertReason',
                'reverted',
                'result.reverted'
            ),
            'ORIGIN',
            REGEXP_REPLACE(REGEXP_REPLACE(path, '[^0-9]+', '_'), '^_|_$', '')
        ) AS trace_address,
        _inserted_timestamp,
        OBJECT_AGG(
            key,
            VALUE
        ) AS trace_json,
        CASE
            WHEN trace_address = 'ORIGIN' THEN NULL
            WHEN POSITION(
                '_' IN trace_address
            ) = 0 THEN 'ORIGIN'
            ELSE REGEXP_REPLACE(
                trace_address,
                '_[0-9]+$',
                '',
                1,
                1
            )
        END AS parent_trace_address,
        SPLIT(
            trace_address,
            '_'
        ) AS trace_address_array
    FROM
        bronze_traces txs,
        TABLE(
            FLATTEN(
                input => PARSE_JSON(
                    txs.full_traces
                ),
                recursive => TRUE
            )
        ) f
    WHERE
        f.index IS NULL
        AND f.key != 'calls'
        AND f.path != 'result'
        AND f.key not in ('message', 'contract')
    GROUP BY
        block_number,
        tx_position,
        partition_key,
        trace_address,
        _inserted_timestamp
)
SELECT
    block_number,
    tx_position,
    trace_address,
    parent_trace_address,
    trace_address_array,
    trace_json,
    partition_key,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['block_number', 'tx_position', 'trace_address']
    ) }} AS traces_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    flatten_traces qualify(ROW_NUMBER() over(PARTITION BY traces_id
ORDER BY
    _inserted_timestamp DESC)) = 1