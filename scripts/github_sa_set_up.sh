

# Variables
ENV=$1

PROJECT_ID=$(gcloud projects list --filter="name=$ENV" --format="value(projectId)")
PROJECT_NUMBER=$(gcloud projects list --filter="name=$ENV" --format="value(projectNumber)")
REPO_OWNER=$2
IDENTITY="github-actions"
SERVICE_ACCOUNT_NAME="github-actions"
SERVICE_ACCOUNT_ID="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

ROLES=(
  "roles/artifactregistry.reader"
  "roles/artifactregistry.writer"
  "roles/run.admin"
  "roles/iam.serviceAccountUser"
  "roles/secretmanager.secretAccessor"
  "roles/iam.serviceAccountTokenCreator"
)

gcloud config set project $PROJECT_ID

gcloud iam workload-identity-pools create $IDENTITY \
    --location="global" \
    --description="Allow github actions to connect to GCP" \
    --display-name="$IDENTITY"


gcloud iam workload-identity-pools providers create-oidc $IDENTITY \
 --location="global" \
 --workload-identity-pool="$IDENTITY" \
 --issuer-uri="https://token.actions.githubusercontent.com" \
 --attribute-mapping="google.subject=assertion.sub,attribute.repository_owner=assertion.repository_owner" \
 --attribute-condition="assertion.repository_owner==\"$REPO_OWNER\""

gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
 --display-name="$SERVICE_ACCOUNT_NAME"

for ROLE in "${ROLES[@]}"; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member "$SERVICE_ACCOUNT_ID" \
    --role "$ROLE"
done

case "$ENV" in
  development) SHORT_ENV="dev" ;;
  staging) SHORT_ENV="stg" ;;
  production) SHORT_ENV="prd" ;;
  *) 
    echo "Error: Invalid ENV value '$ENV'. Expected development, staging, or production."
    exit 1
    ;;
esac

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
 --role=roles/iam.workloadIdentityUser \
 --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$IDENTITY/attribute.repository_owner/$REPO_OWNER"