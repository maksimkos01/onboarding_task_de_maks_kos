export PROJECT_ID="syntio-onboarding-prod"
export REGION="europe-west1"
export TOPIC_NAME_US="mk-us-sales-topic"
export TOPIC_NAME_BR="mk-br-sales-topic"
export DLT_US="mk-us-sales-dlt"
export DLT_BR="mk-br-sales-dlt"


# Create pubsub topics
gcloud pubsub topics create $TOPIC_NAME_US --project=$PROJECT_ID
gcloud pubsub topics create $TOPIC_NAME_BR --project=$PROJECT_ID
gcloud pubsub topics create $DLT_US --project=$PROJECT_ID
gcloud pubsub topics create $DLT_BR --project=$PROJECT_ID



# Create service account
gcloud iam service-accounts create kafka-consumer-sa \
    --display-name="Kafka Consumer Runtime Identity"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:kafka-consumer-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/pubsub.publisher"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:kafka-consumer-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

#Deploy to Cloud Run
gcloud artifacts repositories create mk-kafka-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="Repository for Kafka consumer images" \
    --project=$PROJECT_ID

#build the image
gcloud builds submit --tag europe-west1-docker.pkg.dev/syntio-onboarding-prod/mk-kafka-repo/kafka-consumer:v2 #PAZI

# Deploy the service to Cloud Run
gcloud run deploy mk-kafka-consumer-to-pubsub \
  --image europe-west1-docker.pkg.dev/syntio-onboarding-prod/mk-kafka-repo/kafka-consumer:v2 \
  --region=$REGION \
  --project=$PROJECT_ID \
  --service-account kafka-consumer-sa@syntio-onboarding-prod.iam.gserviceaccount.com
