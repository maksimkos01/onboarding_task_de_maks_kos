WITH snapshot_products AS (
    SELECT * FROM {{ ref('snp_dim_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['model_id_us', 'dbt_valid_from']) }} AS model_id,
    model,
    make,
    category,
    year,
    model_name,
    is_in_production,
    first_produced,
    model_id_us,
    model_id_br,
    price,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current

FROM snapshot_products
