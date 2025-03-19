# GitHub Actions Workflows for Application Deployment

This document describes the GitHub Actions workflows used to build and deploy sensor applications to different environments (development, staging, production).

## Workflows

### 1. Deploy dev APP

This workflow is triggered when code is pushed to the `development` or `dev` branches. It builds and publishes Docker images for two sensor applications and deploys them to Cloud Run in the development environment.

**Trigger:**

* `push` to `development` or `dev` branches.

**Environment Variables:**

* `IMAGE_NAME`: `sensor` (base image name)
* `ARTIFACT_REGION`: `europe-southwest1` (Artifact Registry region)
* `ARTIFACT`: `sensors` (Artifact Registry repository name)
* `REGISTRY`: `docker.pkg.dev` (Artifact Registry host)
* `TOPIC_PATH_SECRET`: `sensors` (Secret name for Pub/Sub topic path)

**Jobs:**

1.  **`build-publish-sensors`:**
    * **Permissions:** `contents: read`, `id-token: write`
    * **Runs On:** `ubuntu-latest`
    * **Strategy:** Matrix strategy to build images for `sensor1` and `sensor2`.
    * **Steps:**
        * **Checkout:** Checks out the repository code.
        * **Authenticate with Google Cloud:** Authenticates with GCP using Workload Identity.
        * **Login to Artifact Registry:** Logs in to Artifact Registry using the authenticated credentials.
        * **Build and Publish Docker Image:** Builds and pushes the Docker image using the `build-publish` composite action.

2.  **`deploy-sensors`:**
    * **Needs:** `build-publish-sensors`
    * **Permissions:** `contents: read`, `id-token: write`
    * **Runs On:** `ubuntu-latest`
    * **Strategy:** Matrix strategy to deploy `sensor1` and `sensor2` to their respective regions.
    * **Steps:**
        * **Checkout Code:** Checks out the repository code.
        * **Deploy service:** Deploys the Cloud Run service using the `deploy` composite action.

### 2. Deploy prd APP

This workflow is triggered when code is pushed to the `main` or `master` branches. It builds and publishes Docker images for two sensor applications and deploys them to Cloud Run in the production environment.

**Trigger:**

* `push` to `main` or `master` branches.

**Environment Variables:**

* `IMAGE_NAME`: `sensor` (base image name)
* `GCP_REGION`: `europe-southwest1` (Default GCP region, you should change this)

**Jobs:**

1.  **`build-publish-sensor-1`:**
    * **Runs On:** `ubuntu-latest`
    * **Steps:**
        * **Checkout Code:** Checks out the repository code.
        * **Authenticate with Google Cloud:** Authenticates with GCP using Workload Identity.
        * **Build and Publish Docker Image:** Builds and pushes the Docker image for `sensor1` using the `build-publish` composite action.

2.  **`build-publish-sensor-2`:**
    * **Runs On:** `ubuntu-latest`
    * **Steps:**
        * **Checkout Code:** Checks out the repository code.
        * **Build and Publish Docker Image:** Builds and pushes the Docker image for `sensor2` using the `build-publish` composite action.

### 3. Deploy stg APP

This workflow is triggered when code is pushed to the `staging` or `stg` branches. It builds and publishes Docker images for two sensor applications and deploys them to Cloud Run in the staging environment.

**Trigger:**

* `push` to `staging` or `stg` branches.

**Environment Variables:**

* `IMAGE_NAME`: `sensor` (base image name)
* `GCP_REGION_SOUTHWEST1`: `europe-west3` (GCP region for sensor 1)
* `GCP_REGION_SOUTHWEST2`: `europe-west4` (GCP region for sensor 2)

**Jobs:**

1.  **`build-publish-sensor-1`:**
    * **Runs On:** `ubuntu-latest`
    * **Steps:**
        * **Checkout Code:** Checks out the repository code.
        * **Authenticate with Google Cloud:** Authenticates with GCP using Workload Identity.
        * **Build and Publish Docker Image:** Builds and pushes the Docker image for `sensor1` using the `build-publish` composite action.

2.  **`build-publish-sensor-2`:**
    * **Runs On:** `ubuntu-latest`
    * **Steps:**
        * **Checkout Code:** Checks out the repository code.
        * **Build and Publish Docker Image:** Builds and pushes the Docker image for `sensor2` using the `build-publish` composite action.

## Composite Actions

### 1. build-publish

This composite action builds and pushes a Docker image to Artifact Registry.

**Inputs:**

* `image_name`: Name of the Docker image.
* `artifact`: Artifact Registry repository name.
* `project_id`: GCP project ID.
* `region`: GCP region.

**Steps:**

1.  **Checkout:** Checks out the repository code.
2.  **Configure Docker to use gcloud CLI:** Configures Docker to use `gcloud` for authentication.
3.  **Build image:** Builds and pushes the Docker image.

### 2. deploy

This composite action deploys a Cloud Run service.

**Inputs:**

* `image_name`: Name of the Docker image.
* `service_name`: Cloud Run service name.
* `artifact`: Artifact Registry repository name.
* `gcp_project_id`: GCP project ID.
* `gcp_region`: GCP region.
* `envs`: Environment variables (key=value).
* `encrypted_envs`: Encrypted environment variables (key=secret_name).
* `workload_identity_provider`: GCP Workload Identity Provider.
* `service_account`: GCP Service Account.

**Steps:**

1.  **Checkout:** Checks out the repository code.
2.  **Authenticate with Google Cloud:** Authenticates with GCP using Workload Identity.
3.  **Set up Cloud SDK:** Sets up the `gcloud` CLI.
4.  **Prepare encrypted env vars:** Prepares encrypted environment variables for deployment.
5.  **Deploy to Cloud Run:** Deploys the Cloud Run service.