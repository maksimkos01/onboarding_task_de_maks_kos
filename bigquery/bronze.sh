#!/bin/bash
export REGION="europe-west1"
export PROJECT_ID="syntio-onboarding-prod"
export BRONZE="mk_bronze"
export GS_PRODUCTS="gs://syn-onboard-product-prod/*.csv"
export GS_STORES="gs://syn-onboard-stores-prod/2025-04-15/*,gs://syn-onboard-stores-prod/2025-07-01/*"

# Creating definition for Products
bq mkdef \
  --autodetect \
  --source_format=CSV \
  "$GS_PRODUCTS" > bigquery/products_def.json

# Creating Products Table
bq mk --location=$REGION \
  --external_table_definition=bigquery/products_def.json \
  "${PROJECT_ID}:${BRONZE}.products"


bq mkdef \
  --autodetect \
  --source_format=NEWLINE_DELIMITED_JSON \
  "$GS_STORES" > bigquery/stores_def.json

bq mk --location=$REGION \
  --external_table_definition=bigquery/stores_def.json \
  "${PROJECT_ID}:${BRONZE}.stores"


bq query --use_legacy_sql=false < bigquery/ddl/create_us_sales.sql  

bq query --use_legacy_sql=false < bigquery/ddl/create_br_sales.sql
