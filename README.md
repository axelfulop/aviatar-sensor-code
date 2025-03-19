# GitHub Actions Workflows for Application Deployment

This document describes the GitHub Actions workflows used to build and deploy sensor applications to different environments (development, staging, production).

## Workflows

### 1. Build image APP

This workflow is triggered by pull requests (PRs) targeting `dev`, `staging`, `stg`, `development`, and `main` branches, or manually via `workflow_dispatch`. It builds and publishes Docker images for sensor applications based on the selected environment and sensor ID.

**Triggers:**

* `pull_request` to `dev`, `staging`, `stg`, `development`, `main` branches.
* `workflow_dispatch` with environment and sensor ID selection.

**Inputs (for workflow_dispatch):**

* `environment`: Environment to deploy to (dev, stg, prd).
* `sensor_id`: Sensor ID (1 or 2).

**Environment Variables:**

* `IMAGE_NAME`: `sensor` (base image name)
* `ARTIFACT_REGION`: `europe-southwest1` (Artifact Registry region, will be updated based on environment)
* `ARTIFACT`: `sensors` (Artifact Registry repository name)
* `REGISTRY`: `docker.pkg.dev` (Artifact Registry host)
* `TOPIC_PATH_SECRET`: `sensors` (Secret name for Pub/Sub topic path)

**Jobs:**

1.  **`build-publish-sensors`:**
    * **Permissions:** `contents: read`, `id-token: write`
    * **Runs On:** `ubuntu-latest`
    * **Steps:**
        * **Checkout:** Checks out the repository code.
        * **Set Environment Variables:** Sets environment variables based on the trigger (PR or manual dispatch) and selected environment.
        * **Authenticate with Google Cloud:** Authenticates with GCP using Workload Identity.
        * **Login to Artifact Registry:** Logs in to Artifact Registry using the authenticated credentials.
        * **Build and Publish Docker Image:** Builds and pushes the Docker image using the `build-publish` composite action.

### 2. Deploy dev APP

This workflow is triggered when code is pushed to the `development` or `dev` branches. It builds and publishes Docker images for two sensor applications and deploys them to Cloud Run in the development environment.

**(Details as provided in the previous response)**

### 3. Deploy prd APP

This workflow is triggered when code is pushed to the `main` or `master` branches. It builds and publishes Docker images for two sensor applications and deploys them to Cloud Run in the production environment.

**(Details as provided in the previous response)**

### 4. Deploy stg APP

This workflow is triggered when code is pushed to the `staging` or `stg` branches. It builds and publishes Docker images for two sensor applications and deploys them to Cloud Run in the staging environment.

**(Details as provided in the previous response)**

## Composite Actions

### 1. build-publish

This composite action builds and pushes a Docker image to Artifact Registry.

**(Details as provided in the previous response)**

### 2. deploy

This composite action deploys a Cloud Run service.

**(Details as provided in the previous response)**
