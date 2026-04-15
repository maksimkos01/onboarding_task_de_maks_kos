{% snapshot snp_dim_stores %}

{{
    config(
      target_schema='mk_gold',
      unique_key='src_store_id',
      strategy='check',
      check_cols='all'
    )
}}

SELECT
    store_id AS src_store_id,
    store_name,
    store_address AS address,
    country_code,
    post_code
FROM {{ ref('stg_stores') }}

{% endsnapshot %}
