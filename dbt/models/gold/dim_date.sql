WITH date_series AS (
    SELECT 
        date_day
    FROM 
        UNNEST(GENERATE_DATE_ARRAY('2000-01-01', '2030-12-31', INTERVAL 1 DAY)) AS date_day
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} AS date_key,
    date_day,
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(QUARTER FROM date_day) AS quarter,
    EXTRACT(MONTH FROM date_day) AS month,
    FORMAT_DATE('%B', date_day) AS month_name,
    EXTRACT(DAY FROM date_day) AS day_of_month,
    EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
    FORMAT_DATE('%A', date_day) AS day_name,
    EXTRACT(DAYOFYEAR FROM date_day) AS day_of_year,
    -- Flags for analysis
    CASE WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    LAST_DAY(date_day, MONTH) AS last_day_of_month

FROM date_series
