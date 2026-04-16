WITH source AS (
    SELECT * FROM {{ source('bronze_layer', 'products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['USModelID', 'BRModelID', 'Year']) }} AS model_key,
    Model AS model,
    Make AS make,
    Category AS category,
    CAST(Year AS STRING) AS year,
    DisplayName AS model_name,
    IsInProduction AS is_in_production,
    FirstProducedModel AS first_produced,
    USModelID AS model_id_us,
    BRModelID AS model_id_br,
    DisplayPriceTagUSD AS price
FROM source
