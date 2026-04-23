#!/bin/bash

set -e

export PROJECT_ID="syntio-onboarding-prod"
export POOL_NAME="mk-github-pool"
export WORKLOAD_IDENTITY_PROVIDER="mk-github-provider"
export SERVICE_ACCOUNT_NAME="mk-github-actions-sa"
export GH_SA="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
export REPO="maksimkos01/onboarding_task_de_maks_kos"

echo "Checking environment for Project: $PROJECT_ID..."

# 1. Create or Skip Workload Identity Pool
if gcloud iam workload-identity-pools describe "${POOL_NAME}" --project="${PROJECT_ID}" --location="global" &>/dev/null; then
    echo "Check: Workload Identity Pool '${POOL_NAME}' already exists. Skipping creation."
else
    echo "Action: Creating Workload Identity Pool '${POOL_NAME}'..."
    gcloud iam workload-identity-pools create "${POOL_NAME}" \
        --project="${PROJECT_ID}" \
        --location="global" \
        --display-name="GitHub Actions Pool"
fi

# 2. Create or Skip Workload Identity Provider
if gcloud iam workload-identity-pools providers describe "${WORKLOAD_IDENTITY_PROVIDER}" \
    --project="${PROJECT_ID}" --location="global" --workload-identity-pool="${POOL_NAME}" &>/dev/null; then
    echo "Check: Provider '${WORKLOAD_IDENTITY_PROVIDER}' already exists. Skipping creation."
else
    echo "Action: Creating Workload Identity Provider..."
    gcloud iam workload-identity-pools providers create-oidc "${WORKLOAD_IDENTITY_PROVIDER}" \
        --project="${PROJECT_ID}" \
        --location="global" \
        --workload-identity-pool="${POOL_NAME}" \
        --display-name="GitHub Provider" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
        --attribute-condition="assertion.repository == '${REPO}'" \
        --issuer-uri="https://token.actions.githubusercontent.com"
fi

# 3. Create or Skip Service Account
if gcloud iam service-accounts describe "${GH_SA}" --project="${PROJECT_ID}" &>/dev/null; then
    echo "Check: Service Account '${GH_SA}' already exists. Skipping creation."
else
    echo "Action: Creating Service Account '${GH_SA}'..."
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
        --display-name="GitHub Actions Service Account" \
        --project="${PROJECT_ID}"
fi

# 4. Apply IAM Roles (gcloud add-iam-policy-binding is idempotent by default)
echo "Action: Ensuring IAM roles are bound to ${GH_SA}..."

ROLES=(
    "roles/run.admin"
    "roles/cloudbuild.builds.editor"
    "roles/iam.serviceAccountAdmin"
    "roles/resourcemanager.projectIamAdmin"
    "roles/artifactregistry.admin"
    "roles/bigquery.admin"
    "roles/pubsub.admin"
    "roles/secretmanager.admin"
    "roles/dataplex.admin"
    "roles/workflows.admin"
    "roles/cloudscheduler.admin"
    "roles/iam.serviceAccountUser"
    "roles/serviceusage.serviceUsageConsumer"
    "roles/storage.admin"
)

for ROLE in "${ROLES[@]}"; do
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
        --member="serviceAccount:${GH_SA}" \
        --role="${ROLE}" \
        --quiet &>/dev/null
done

# 5. Bind Repository to Service Account (Workload Identity User)
echo "Action: Binding GitHub repository to Service Account via Workload Identity..."

# Get the full Workload Identity Pool ID (needed for the binding)
WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe "${POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --format='value(name)')

gcloud iam service-accounts add-iam-policy-binding "${GH_SA}" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}" \
    --quiet &>/dev/null

echo "Setup Complete!"
