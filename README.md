
# Building and Publishing SnarkOS Docker Image

### GitHub Actions Build & Push (CI/CD Workflow)

You can also trigger a manual build and push via GitHub Actions.

#### Steps:

1. Go to the **Actions** tab in GitHub.
2. Select **Build and Push SnarkOS Multi-Arch Docker Image** workflow.
3. Click **Run workflow**.

#### Parameters:

* `git_ref`: Git commit SHA, branch, or tag (example: `canary-v3.8.0`)
* `image_tag`: Desired image tag for Artifact Registry (example: `v3.8.0-canary-20250610`)
* `network_name`: One of `mainnet`, `testnet`, `canary`

#### Result:

The image will be pushed to:

```
us-east1-docker.pkg.dev/<GCP_PROJECT>/snarkos-containers/snarkos:<image_tag>
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

### Example Tagging Convention:

| Scenario              | Suggested Tag             |
| --------------------- | ------------------------- |
| Canary release build  | `v3.8.0-canary-20250610`  |
| Testnet release build | `v3.8.0-testnet-20250610` |
| Mainnet release build | `v3.8.0-mainnet-20250610` |
| Manual git sha build  | `<short_sha>-canary`      |

---

# Initial Terraform Quick start 
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

# Initial set up
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

### 4. Run terragrunt
### 5. Once registry, roles, service account have been created. 
- Go to anf-builder service account and create a key.
### 6. Add key to Github actions > Secrets > GCP_SA_BUILDER_KEY.