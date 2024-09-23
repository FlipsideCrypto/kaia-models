-- depends_on: {{ ref('bronze__streamline_traces') }}
{{ config (
    materialized = "incremental",
    incremental_strategy = 'delete+insert',
    unique_key = "block_number",
    cluster_by = ['modified_timestamp::DATE','partition_key'],
    full_refresh = false,
    tags = ['traces_reload']
) }}

{{ fsc_evm.silver_traces_v1(
    full_reload_start_block = 9000000,
    full_reload_blocks = 25000000,
    full_reload_mode = true,
    use_partition_key = true
) }}