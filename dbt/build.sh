export PROJECT_ID="syntio-onboarding-prod"
export REPO_NAME="mk-kafka-repo"
export REGION="europe-west1"
export SERVICE_ACCOUNT_EMAIL="dbt-mk-user@syntio-onboarding-prod.iam.gserviceaccount.com"
export IMAGE_TAG="europe-west1-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/dbt-onboarding:v1"

docker build -t $IMAGE_TAG .

docker push $IMAGE_TAG

gcloud run jobs create dbt-medallion-job \
    --image $IMAGE_TAG \
    --region $REGION \
    --service-account $SERVICE_ACCOUNT_EMAIL

# to execute the job:
# gcloud run jobs execute dbt-medallion-job
