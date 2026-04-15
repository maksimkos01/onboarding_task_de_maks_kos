
WITH silver_stores AS (
    SELECT * FROM {{ ref('stg_stores') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['store_id']) }} AS store_id,
    store_id AS src_store_id,
    store_name,
    store_address AS address,
    country_code,
    post_code

FROM silver_stores
