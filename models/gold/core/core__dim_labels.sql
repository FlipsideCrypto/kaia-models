{{ config(
    materialized = 'incremental',
    unique_key = ['address', 'blockchain'],
    incremental_strategy = 'merge',
    cluster_by = 'modified_timestamp::DATE',
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(address, creator, label_type, label_subtype, address_name, project_name), SUBSTRING(address, creator, label_type, label_subtype, address_name, project_name)",
    tags = ['non_realtime']
) }}

SELECT
    'kaia' AS blockchain,
    creator,
    address,
    address_name,
    label_type,
    label_subtype,
    project_name,
    labels_combined_id AS dim_labels_id,
    inserted_timestamp,
    modified_timestamp
FROM
    {{ source(
        'klaytn_silver',
        'labels'
    ) }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(
                modified_timestamp
            )
        FROM
            {{ this }}
    )
{% endif %}
