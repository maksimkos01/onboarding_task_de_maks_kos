{% snapshot snp_dim_products %}

{{
    config(
      target_schema='mk_gold', 
      unique_key='model_key',    
      strategy='check',
      check_cols='all'
    )
}}

SELECT * FROM {{ ref('stg_products') }}

{% endsnapshot %}
