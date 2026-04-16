export LOCATION="europe-west1"
export PROJECT_ID="syntio-onboarding-prod"
export DATASET_ID="mk_gold"
export DATA_SOURCE_BASE="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/$DATASET_ID/tables"

# Create the data quality scans
gcloud dataplex datascans create data-quality products-dq-scan \
    --location="$LOCATION" \
    --data-source-resource="$DATA_SOURCE_BASE/dim_products" \
    --data-quality-spec-file="rules/dq_products.yaml" 


gcloud dataplex datascans create data-quality employee-dq-scan \
    --location="$LOCATION" \
    --data-source-resource="$DATA_SOURCE_BASE/dim_employee" \
    --data-quality-spec-file="rules/dq_employee.yaml"


gcloud dataplex datascans create data-quality stores-dq-scan \
    --location="$LOCATION" \
    --data-source-resource="$DATA_SOURCE_BASE/dim_stores" \
    --data-quality-spec-file="rules/dq_stores.yaml"


# Run the scan 
gcloud dataplex datascans run products-dq-scan --location="$LOCATION"
gcloud dataplex datascans run employee-dq-scan --location="$LOCATION" 
gcloud dataplex datascans run stores-dq-scan --location="$LOCATION" 
