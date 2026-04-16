WITH snapshot_employees AS (
    SELECT * FROM {{ ref('snp_dim_employee') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['employee_key', 'dbt_valid_from']) }} AS employee_id,
    src_employee_id,
    first_name,
    last_name,
    phone_number,
    position,
    hired_on,
    address,
    country_code,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current

FROM snapshot_employees
