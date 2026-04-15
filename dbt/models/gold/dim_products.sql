WITH source AS (
    SELECT * FROM {{ source('bronze_layer', 'products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['Model']) }} AS model_id,
    Model as src_model_id,
    Make as make,
    Category as category,
    CAST(Year as STRING) as year,
    DisplayName as model_name,
    IsInProduction as is_in_production,
    FirstProducedModel as first_produced,
    USModelID as model_id_us,
    BRModelID as model_id_br,
    DisplayPriceTagUSD as price
FROM source
