# snarkos-docker
Repo to build docker image for each release/update and push to gcp registry.
### 3. Create Terraform Service Account

```bash
gcloud iam service-accounts create terraform-sa --display-name "Terraform Service Account"
```

---

### 4. Assign IAM Roles

Replace `<PROJECT_NAME>` with your actual project name.

```bash
for role in \
  roles/compute.admin \
  roles/storage.admin \
  roles/iam.serviceAccountUser \
  roles/compute.networkAdmin \
  roles/dns.admin \
  roles/container.admin \
  roles/serviceusage.serviceUsageAdmin; do
    gcloud projects add-iam-policy-binding <PROJECT_NAME> \
      --member=serviceAccount:terraform-sa@<PROJECT_NAME>.iam.gserviceaccount.com \
      --role=$role
done
```