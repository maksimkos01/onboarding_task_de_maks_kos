WITH source AS (
    SELECT 
        StoreID AS store_id,
        CountryCode AS country_code,
        Employees 
    FROM {{ source('bronze_layer', 'stores') }}
)

SELECT
    store_id,
    country_code,
    emp.EmployeeID AS employee_id,
    emp.FirstName AS first_name,
    emp.LastName AS last_name,
    CONCAT(emp.FirstName, ' ', emp.LastName) AS full_name,
    emp.JobPosition AS job_position,
    emp.HiredOn AS hired_on,
    emp.PhoneNumber AS phone_number,
    emp.Address AS employee_address
FROM source,
UNNEST(Employees) AS emp
