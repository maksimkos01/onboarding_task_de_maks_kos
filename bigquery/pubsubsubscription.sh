# Project and Region
export REGION="europe-west1"
export PROJECT_ID="syntio-onboarding-prod"
export BRONZE="mk_bronze"

# Dataset and Tables
export TABLE_US="us_sales"
export TABLE_BR="br_sales"

# Topics
export TOPIC_US="mk-us-sales-topic"
export TOPIC_BR="mk-br-sales-topic"
export DLT_US="mk-us-sales-dlt"
export DLT_BR="mk-br-sales-dlt"

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
# Define the Pub/Sub Service Account
export PUBSUB_SERVICE_ACCOUNT="service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com"

# Grant BigQuery Data Editor
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PUBSUB_SERVICE_ACCOUNT" \
    --role="roles/bigquery.dataEditor"

# Grant Publisher role on DLT topics
gcloud pubsub topics add-iam-policy-binding $DLT_US \
    --member="serviceAccount:$PUBSUB_SERVICE_ACCOUNT" \
    --role="roles/pubsub.publisher"

gcloud pubsub topics add-iam-policy-binding $DLT_BR \
    --member="serviceAccount:$PUBSUB_SERVICE_ACCOUNT" \
    --role="roles/pubsub.publisher"

# Create US Sales Subscription
gcloud pubsub subscriptions create mk-us-sales-bq-sub \
    --topic=$TOPIC_US \
    --bigquery-table=$PROJECT_ID:$BRONZE.$TABLE_US \
    --use-table-schema \
    --dead-letter-topic=$DLT_US \
    --max-delivery-attempts=5

# Create BR Sales Subscription
gcloud pubsub subscriptions create mk-br-sales-bq-sub \
    --topic=$TOPIC_BR \
    --bigquery-table=$PROJECT_ID:$BRONZE.$TABLE_BR \
    --use-table-schema \
    --dead-letter-topic=$DLT_BR \
    --max-delivery-attempts=5

# Allows Pub/Sub to consume the message and move it to the DLT
gcloud pubsub subscriptions add-iam-policy-binding mk-us-sales-bq-sub \
    --member="serviceAccount:$PUBSUB_SERVICE_ACCOUNT" \
    --role="roles/pubsub.subscriber"

gcloud pubsub subscriptions add-iam-policy-binding mk-br-sales-bq-sub \
    --member="serviceAccount:$PUBSUB_SERVICE_ACCOUNT" \
    --role="roles/pubsub.subscriber"

gcloud pubsub subscriptions create mk-us-sales-dlt-sub \
    --topic=$DLT_US \
    --project=$PROJECT_ID
