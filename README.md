
# Building and Publishing SnarkOS Docker Image

### GitHub Actions Build & Push (CI/CD Workflow)

You can also trigger a manual build and push via GitHub Actions.

#### Steps:

1. Go to the **Actions** tab in GitHub.
2. Select **Build and Push SnarkOS Multi-Arch Docker Image** workflow.
3. Click **Run workflow**.

#### Parameters:

* `git_ref`: Git commit SHA or tag (example: `5f58ab1 or v3.8.0`)
* `image_tag`: Desired image tag for Artifact Registry (example: `canary-latest, testnet-latest, mainnet-latest`)
* `network_name`: One of `mainnet`, `testnet`, `canary`

#### Result:

The image will be pushed to:

```
us-east1-docker.pkg.dev/<GCP_PROJECT>/snarkos-containers/snarkos:<image_tag>
```
---

# Initial Terraform set up
### 1. Create Terraform Service Account

```bash
gcloud iam service-accounts create terraform-sa --display-name "Terraform Service Account"
```

---

### 2. Assign IAM Roles

Replace `<PROJECT_NAME>` with your actual project name.

```bash
for role in \
  roles/artifactregistry.admin \
  roles/iam.securityAdmin \
  roles/iam.workloadIdentityPoolAdmin \
  roles/iam.serviceAccountAdmin \
  roles/storage.admin \
  roles/storage.objectAdmin; do
    gcloud projects add-iam-policy-binding <PROJECT_NAME> \
      --member=serviceAccount:terraform-sa@<PROJECT_NAME>.iam.gserviceaccount.com \
      --role=$role
done
```

### 3. Create Terraform State Bucket

```bash
gsutil mb -p <PROJECT_NAME> gs://<PROJECT_NAME>-provable-tfstate
gsutil versioning set on gs://<PROJECT_NAME>-provable-tfstate
```

Update `envs/<env>/terragrunt.hcl`:

```hcl
remote_state {
  backend = "gcs"
  config = {
    bucket   = "<PROJECT_NAME>-provable-tfstate"
    prefix   = "terraform/state"
    project  = "<PROJECT_NAME>"
    location = "<GCP_REGION>"
  }
}
```

### 4. Initialize and Apply Terraform

```bash
cd envs/{test}
terragrunt init  
terragrunt plan  
terragrunt apply
```
### 5. Create key for anf-builder service account
```bash
gcloud iam service-accounts keys create anf-builder-key.json \
  --iam-account=anf-builder@YOUR_PROJECT_ID.iam.gserviceaccount.com
```
### 6. Create GH Secret with anf-builder key 
`Github Actions > Secrets > GCP_SA_IMG_BUILDER_KEY`

---
# Terraform Quick start 
### 1. Set Environment and Download Secrets

```bash
./scripts/download_secrets.sh  # Choose: test, canary, testnet, mainnet
source scripts/set_env.sh  # Choose: test, canary, testnet, mainnet
```

---

### 2. Initialize and Apply Terraform

```bash
cd envs/{test}
terragrunt init  
terragrunt plan  
terragrunt apply
```
# Initial VM setup to pull image
### 1. Install gcloud
```bash
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud public key
sudo apt-get install -y apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null

# Update and install the Cloud SDK
sudo apt-get update && sudo apt-get install -y google-cloud-sdk
```
### 2. Authenticate gcloud with GCP service account key
```bash
gcloud auth activate-service-account --key-file=<PATH_TO_SA_KEY>
gcloud auth configure-docker us-east1-docker.pkg.dev
```
### 3. Pull docker image
```bash
docker pull us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/<NETWORK>/snarkos:<NETWORK>-latest
```
---
### CANARY CLIENT - Run docker container as canary client
```bash
docker run -d --name canary-client \
  -e FUNC=client \
  -e NETWORK=2 \
  -e REST_RPS=20 \
  -e LOGLEVEL=4 \
  -e ALEO_PRIVKEY="" \
  -e PEERS="<OTHER_CLIENT_AND_VALIDATOR_IPs>:4130" \
  us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/canary/snarkos:canary-latest

docker logs -f canary-client
```
#### Check snarkos version
```bash
docker exec -it canary-client /aleo/bin/snarkos --version
```
### CANARY VALIDATOR - Run docker container as canary validator
```bash
docker run -d --name canary-validator \
  -e FUNC=validator \
  -e NETWORK=2 \
  -e REST_RPS=20 \
  -e LOGLEVEL=4 \
  -e ALEO_PRIVKEY="" \
  -e PEERS="<OTHER_CLIENT_AND_VALIDATOR_IPs>:4130" \
  -e VALIDATORS="<OTHER_VALIDATOR_IPs>:5000" \
  us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/canary/snarkos:canary-latest
```
```bash
docker logs -f canary-validator
```
---
### TESTNET IMAGE
```bash
docker pull us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/testnet/snarkos:testnet-latest
```
### TESTNET CLIENT
```bash
docker run -d --name testnet-client \
  -e FUNC=client \
  -e NETWORK=1 \
  -e REST_RPS=20 \
  -e LOGLEVEL=4 \
  -e ALEO_PRIVKEY="" \
  -e PEERS="<OTHER_CLIENT_AND_VALIDATOR_IPs>:4130" \
  us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/testnet/snarkos:testnet-latest && docker logs -f testnet-client

docker exec -it testnet-client /aleo/bin/snarkos --version
```

### TESTNET VALIDATOR
```bash
docker run -d --name testnet-validator \
  -e FUNC=validator \
  -e NETWORK=1 \
  -e REST_RPS=20 \
  -e LOGLEVEL=4 \
  -e ALEO_PRIVKEY="" \
  -e PEERS="<OTHER_CLIENT_AND_VALIDATOR_IPs>:4130" \
  -e VALIDATORS="<OTHER_VALIDATOR_IPs>:5000" \
  us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/testnet/snarkos:testnet-latest && docker logs -f testnet-validator

docker exec -it testnet-validator /aleo/bin/snarkos --version
```
---
### MAINNET IMAGE
```bash
docker pull us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/mainnet/snarkos:mainnet-latest
```
### MAINNET CLIENT
```bash
docker run -d --name mainnet-client \
  -e FUNC=client \
  -e NETWORK=0 \
  -e REST_RPS=20 \
  -e LOGLEVEL=4 \
  -e ALEO_PRIVKEY="" \
  -e PEERS="<OTHER_CLIENT_AND_VALIDATOR_IPs>:4130" \
  us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/mainnet/snarkos:mainnet-latest && docker logs -f mainnet-client

docker exec -it mainnet-client /aleo/bin/snarkos --version
```

### MAINNET VALIDATOR
```bash
docker run -d --name mainnet-validator \
  -e FUNC=validator \
  -e NETWORK=0 \
  -e REST_RPS=20 \
  -e LOGLEVEL=4 \
  -e ALEO_PRIVKEY="" \
  -e PEERS="<OTHER_CLIENT_AND_VALIDATOR_IPs>:4130" \
  -e VALIDATORS="<OTHER_VALIDATOR_IPs>:5000" \
  us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/mainnet/snarkos:mainnet-latest && docker logs -f mainnet-validator

docker exec -it mainnet-validtor /aleo/bin/snarkos --version
```
---
### Local Build (Developer Workflow)

You can build the SnarkOS Docker image locally using `build.sh`.

#### Usage

```bash
./build.sh [git_ref] [network_name] [arch_mode]
```

#### Arguments:

* `git_ref`: Git commit SHA, branch, or tag from snarkOS repo (default: `canary-v3.8.0`)
* `network_name`: One of `mainnet`, `testnet`, `canary` (default: `canary`)
* `arch_mode`: `single` (default) or `multi`

#### Examples:

**Fast local test build (safe on laptop):**

```bash
./build.sh canary-v3.8.0 canary single
```

**Full multi-arch build and push to GCP Artifact Registry:**

```bash
./build.sh canary-v3.8.0 canary multi
```

The image will be pushed to:

```
us-east1-docker.pkg.dev/<GCP_PROJECT>/snarkos-containers/snarkos:<git_ref>-<network_name>
```
### Notes:

* **Local single arch build** is much faster for testing (no QEMU overhead).
* Use **multi arch build** when ready to publish official builds.
* `entrypoint.sh` changes will rebuild fast (no full Rust rebuild required).
* If `GIT_REF` changes, or snarkOS code changes → full Rust rebuild will occur.

---
