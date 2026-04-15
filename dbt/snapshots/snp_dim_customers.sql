{% snapshot snp_dim_customers %}

{{
    config(
      target_schema='mk_gold',
      unique_key='src_customer_id', 
      strategy='check',
      check_cols='all'
    )
}}

WITH us_customers AS (
    SELECT DISTINCT
        CAST(customer_id AS STRING) AS src_customer_id,
        customer_first_name AS first_name,
        customer_last_name AS last_name,
        customer_gender AS gender,
        customer_registered_since AS signup_date,
        customer_country AS country,
        customer_city AS city,
        customer_address AS address,
        customer_phone AS phone,
        referred_by
    FROM {{ ref('stg_us_sales') }}
),

br_customers AS (
    SELECT DISTINCT
        CAST(customer_id AS STRING) AS src_customer_id,
        SPLIT(customer_name, ' ')[SAFE_OFFSET(0)] AS first_name,
        LTRIM(SUBSTR(customer_name, LENGTH(SPLIT(customer_name, ' ')[SAFE_OFFSET(0)]) + 1)) AS last_name,
        CAST(NULL AS STRING) AS gender,
        CAST(NULL AS DATE) AS signup_date, 
        'BR' AS country, 
        CAST(NULL AS STRING) AS city,
        customer_location AS address,
        CAST(NULL AS STRING) AS phone,
        CAST(NULL AS STRING) AS referred_by
    FROM {{ ref('stg_br_sales') }}
),

combined_customers AS (
    SELECT * FROM us_customers
    UNION DISTINCT
    SELECT * FROM br_customers
)

SELECT * FROM combined_customers

{% endsnapshot %}
