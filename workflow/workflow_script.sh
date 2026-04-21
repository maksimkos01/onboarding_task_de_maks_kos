export SERVICE_ACCOUNT="dbt-mk-user@syntio-onboarding-prod.iam.gserviceaccount.com"
export REGION="europe-west1"
export PROJECT_ID="syntio-onboarding-prod"

# Deploy the workflow
gcloud workflows deploy mk-medallion-pipeline \
    --source=pipeline-workflow.yaml \
    --location="$REGION" \
    --service-account="$SERVICE_ACCOUNT"


gcloud scheduler jobs create http daily-medallion-sync \
  --schedule="0 5 * * *" \
  --uri="https://workflowexecutions.googleapis.com/v1/projects/syntio-onboarding-prod/locations/europe-west1/workflows/mk-medallion-pipeline/executions" \
  --message-body="{}" \
  --oauth-service-account-email="$SERVICE_ACCOUNT" \
  --location="$REGION"
