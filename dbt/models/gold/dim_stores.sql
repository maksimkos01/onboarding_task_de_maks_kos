
WITH snapshot_stores AS (
    SELECT * FROM {{ ref('snp_dim_stores') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['src_store_id', 'dbt_valid_from']) }} AS store_id,
    src_store_id,
    store_name,
    address,
    country_code,
    post_code,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
    
FROM snapshot_stores
