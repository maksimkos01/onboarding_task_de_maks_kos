WITH br_sales AS (
    SELECT * FROM {{ ref('stg_br_sales') }}
),

us_sales AS (
    SELECT * FROM {{ ref('stg_us_sales') }}
),


br_aggregated AS (
    SELECT 
        transaction_id AS src_sale_id,
        COUNT(transaction_id) AS quantity,
        SUM(unit_price) AS total_amount
    FROM br_sales
    GROUP BY 1
),


us_aggregated AS (
    SELECT 
        transaction_id AS src_sale_id,
        COUNT(line_num) AS quantity,
        MAX(total_payment_amount) AS total_amount
    FROM us_sales
    GROUP BY 1
),

br_enriched AS (
    SELECT 
        CAST(s.transaction_id AS STRING) AS src_sale_id,
        CAST(s.customer_id AS STRING)AS src_customer_id,
        s.product_model_id AS src_model_id,
        s.store_id AS src_store_id,
        CAST(NULL AS STRING) AS src_employee_id, 
        s.transaction_at,
        s.card_number,
        a.quantity,
        a.total_amount
    FROM br_sales s
    JOIN br_aggregated a 
        ON s.transaction_id = a.src_sale_id
),

us_enriched AS (
    SELECT 
        s.transaction_id AS src_sale_id,
        s.customer_id AS src_customer_id,
        s.product_model_id AS src_model_id,
        s.store_id AS src_store_id,
        s.employee_id AS src_employee_id,
        s.transaction_at,
        s.card_number,
        a.quantity,
        a.total_amount
    FROM us_sales s
    JOIN us_aggregated a 
        ON s.transaction_id = a.src_sale_id
),

combined_sales AS (
    SELECT * FROM br_enriched
    UNION ALL
    SELECT * FROM us_enriched
),

customer AS (
    SELECT customer_id, src_customer_id
    FROM {{ ref('dim_customers') }}
),

product AS (
    SELECT model_id, src_model_id
    FROM {{ ref('dim_products') }}
),

store AS (
    SELECT store_id, src_store_id
    FROM {{ ref('dim_stores') }}
),

employee AS (
    SELECT 
        employee_id, src_employee_id
    FROM {{ ref('dim_employee') }}
),

date_dim AS (
    SELECT 
        date_key AS date_id,
        date_day
    FROM {{ ref('dim_date') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['cs.src_sale_id']) }} AS sale_id,
    cs.src_sale_id,
    c.customer_id,
    p.model_id,
    s.store_id,
    e.employee_id,
    DATE(CAST(cs.transaction_at AS TIMESTAMP)) AS sale_date,
    cs.quantity,
    CONCAT('****-****-****-', RIGHT(CAST(cs.card_number AS STRING), 4)) AS card_number,
    CAST(cs.total_amount AS NUMERIC) AS total_amount,
    DATETIME(CAST(cs.transaction_at AS TIMESTAMP), 'UTC') AS sale_ts,
    d.date_id

FROM combined_sales cs
LEFT JOIN customer c 
    ON CAST(cs.src_customer_id AS STRING) = CAST(c.src_customer_id AS STRING)
LEFT JOIN product p 
    ON CAST(cs.src_model_id AS STRING) = CAST(p.src_model_id AS STRING)
LEFT JOIN store s 
    ON CAST(cs.src_store_id AS STRING) = CAST(s.src_store_id AS STRING)
LEFT JOIN employee e 
    ON CAST(cs.src_employee_id AS STRING) = CAST(e.src_employee_id AS STRING)
LEFT JOIN date_dim d 
    ON DATE(CAST(cs.transaction_at AS TIMESTAMP)) = d.date_day
