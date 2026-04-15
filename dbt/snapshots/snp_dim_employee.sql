{% snapshot snp_dim_employee %}

{{
    config(
      target_schema='mk_gold',
      unique_key='employee_key', 
      strategy='check',
      check_cols='all'
    )
}}

WITH silver_employees AS (
    SELECT * FROM {{ ref('stg_store_employees') }}
)

SELECT
    employee_key,
    CAST(employee_id AS STRING) AS src_employee_id,
    first_name,
    last_name,
    phone_number,
    job_position AS position,
    hired_on,
    employee_address AS address,
    country_code
FROM silver_employees

{% endsnapshot %}
