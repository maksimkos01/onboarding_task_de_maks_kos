WITH source AS (
    SELECT * FROM {{ source('bronze_layer', 'stores') }}
)

SELECT
    StoreID AS store_id,
    StoreName AS store_name,
    CountryCode AS country_code,
    CAST(PostCode AS STRING) AS post_code,
    Address AS store_address
FROM source
