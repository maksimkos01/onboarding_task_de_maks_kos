
CREATE TABLE `syntio-onboarding-prod.mk_bronze.us_sales` (
    transaction_id STRING,
    transaction_time TIMESTAMP,
    store STRING,
    registered_customer STRUCT<
        registered_customer_id STRING,
        first_name STRING,
        last_name STRING,
        gender STRING,
        registered_since DATE,
        address STRUCT<
            country_code STRING,
            city STRING,
            address STRING
        >,
        contact STRUCT<
            phone_number STRING
        >,
        referred_by STRING
    >,
    employee STRING,
    models_purchased ARRAY<STRUCT<
        line_num INT64,
        model STRING,
        model_price NUMERIC
    >>,
    payment STRUCT<
        card_information STRUCT<
            card_number STRING,
            card_expires STRING
        >,
        total STRUCT<
            payment NUMERIC,
            currency STRING
        >
    >
);
