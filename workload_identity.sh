export PROJECT_ID="syntio-onboarding-prod"
export POOL_NAME="mk-github-pool"
export WORKLOAD_IDENTITY_PROVIDER="mk-github-provider"
export SERVICE_ACCOUNT_NAME="mk-github-actions-sa"
export GH_SA="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create the workload identity pool
gcloud iam workload-identity-pools create "${POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global"

# Create the Workload Identity Provider
gcloud iam workload-identity-pools providers create-oidc "${WORKLOAD_IDENTITY_PROVIDER}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="${POOL_NAME}" \
    --display-name="GitHub Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --attribute-condition="assertion.repository == 'maksimkos01/onboarding_task_de_maks_kos'" \
    --issuer-uri="https://token.actions.githubusercontent.com"

# Create a Service Account for the Pipeline
gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
    --display-name="GitHub Actions Service Account"

# 1. Permission to manage Cloud Run Services and Jobs
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/run.admin"

# 2. Permission to submit builds to Cloud Build
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/cloudbuild.builds.editor"

# Grant permissions to create and manage Service Accounts and IAM Policies
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/pubsub.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/secretmanager.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/dataplex.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/workflows.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/cloudscheduler.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GH_SA}" \
    --role="roles/storage.objectViewer"

# Allow the GitHub Repo to Impersonate the SA
# Get the full Workload Identity Pool ID
export WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe "${POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --format='value(name)')

# Bind the repository to the Service Account
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_NAME}@$PROJECT_ID.iam.gserviceaccount.com" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/maksimkos01/onboarding_task_de_maks_kos"
