WITH snapshot_customers AS (
    SELECT * FROM {{ ref('snp_dim_customers') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['src_customer_id', 'dbt_valid_from']) }} AS customer_id,
    src_customer_id,
    first_name,
    last_name,
    gender,
    signup_date,
    country,
    city,
    address,
    phone,
    referred_by,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current

FROM snapshot_customers
