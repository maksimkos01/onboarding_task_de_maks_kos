-- models/silver/stg_us_sales.sql

WITH source AS (
    SELECT * FROM {{ source('bronze_layer', 'us_sales') }}
),

flattened_items AS (
    SELECT
        s.transaction_id,
        s.transaction_time,
        s.store,
        s.employee,
        s.registered_customer.registered_customer_id,
        s.registered_customer.first_name,
        s.registered_customer.last_name,
        s.registered_customer.gender,
        s.registered_customer.registered_since,
        s.registered_customer.address.country_code AS customer_country_code,
        s.registered_customer.address.city AS customer_city,
        s.registered_customer.address.address AS customer_address,
        s.registered_customer.contact.phone_number AS customer_phone,
        s.registered_customer.referred_by AS referred_by,
        s.payment.card_information.card_number AS card_number,
        s.payment.card_information.card_expires AS card_expiry_date,
        s.payment.total.payment AS total_payment_amount,
        s.payment.total.currency AS currency_code,
        item.line_num AS line_num,
        item.model AS product_model_id,
        item.model_price AS unit_price

    FROM source AS s,
    UNNEST(s.models_purchased) AS item
)

SELECT
    transaction_id,
    transaction_time AS transaction_at,
    store AS store_id,
    employee AS employee_id,
    registered_customer_id AS customer_id,
    first_name AS customer_first_name,
    last_name AS customer_last_name,
    gender AS customer_gender,
    registered_since AS customer_registered_since,
    customer_country_code AS customer_country,
    customer_city AS customer_city,
    customer_address AS customer_address,
    customer_phone AS customer_phone,
    referred_by,
    card_number,
    card_expiry_date,
    total_payment_amount,
    currency_code,
    line_num,
    product_model_id,
    unit_price
FROM flattened_items
