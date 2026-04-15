
WITH silver_employees AS (
    SELECT * FROM {{ ref('stg_store_employees') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} AS employee_id,
    CAST(employee_id AS STRING) AS src_employee_id,
    first_name,
    last_name,
    phone_number,
    job_position AS position,
    hired_on,
    employee_address AS address,
    country_code
FROM silver_employees
