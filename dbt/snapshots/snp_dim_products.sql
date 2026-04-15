{% snapshot snp_dim_products %}

{{
    config(
      target_schema='mk_gold', 
      unique_key='model_id_us',    
      strategy='check',
      check_cols='all'
    )
}}

SELECT * FROM {{ ref('stg_products') }}

{% endsnapshot %}
