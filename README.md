# Terraform Helm Platform

A learning project using Terraform to deploy an existing Flask/PostgreSQL Helm chart onto a local kind cluster.

## Scope

Terraform manages:

- Namespace `terraform-lab`.
- PostgreSQL PVC `postgres-data`.
- Helm release `flask-app`.

The cluster and Flask image already exist. This project does not create the cluster or build the application image.

## Prerequisites

- Terraform installed.
- Running kind cluster with context `kind-devops-lab`.
- StorageClass `standard`.
- Image `flask-app:v3` loaded into the cluster.
- The `k8s-helm-flask-app` repository available locally.
- Private Helm values file containing both database passwords.

The original application project and chart are documented at:
https://github.com/Stathis-Tsapras/k8s-helm-flask-app

## Files

- `providers.tf`: provider versions and cluster connections.
- `main.tf`: namespace, PVC and Helm release.
- `variables.tf`: namespace and file path inputs.
- `output.tf`: namespace, release name and access command.
- `.terraform.lock.hcl`: selected provider versions and checksums.
- `.gitignore`: excludes local state, provider downloads and private variable files.

## Configuration

Default inputs:

| Variable | Default |
| --- | --- |
| `namespace` | `terraform-lab` |
| `chart_path` | `~/k8s-helm-flask-app/flask-app` |
| `private_values_path` | `~/devops-lab-private.yaml` |

The private values file stays outside the repository:

```yaml
secrets:
  dbPassword: "REPLACE_WITH_ADMIN_PASSWORD"
  flaskPassword: "REPLACE_WITH_FLASK_PASSWORD"
```

Restrict its permissions:

```bash
chmod 600 ~/devops-lab-private.yaml
```

For an existing database, use its current credentials. Changing Secret values does not change existing PostgreSQL role passwords.

## Deploy

From this repository's directory:

```bash
kubectl config current-context
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Review the plan before entering `yes`.

- `init`: prepares the directory and installs providers.
- `fmt -check`: checks formatting without rewriting files.
- `validate`: checks configuration consistency.
- `plan`: previews proposed changes.
- `apply`: performs the reviewed changes.

The providers explicitly select `kind-devops-lab`.

Terraform creates the namespace, then the PVC, then the Helm release. The PVC does not wait for binding because `standard` uses WaitForFirstConsumer; PostgreSQL's Pod triggers binding.

## Verify

```bash
terraform state list
terraform plan
kubectl get pods,pvc -n terraform-lab
terraform output
```

Verified results:

- Three resources recorded in Terraform state.
- Subsequent plan reported no changes.
- Application pods Ready and PVC Bound.
- Application and health endpoints worked.

Access the application:

```bash
kubectl port-forward -n terraform-lab service/flask-app 9091:8081
```

Keep the terminal running and open these addresses in the Ubuntu VM:

- http://localhost:9091/ — `1 - Kubernetes User`
- http://localhost:9091/health — `OK`
- http://localhost:9091/ready — `Ready`

If you override the namespace, use that namespace in verification commands.

### Destroy and recreate test

Ran `terraform destroy` and confirmed the state was empty and the namespace was removed. A subsequent plan showed three resources to create.

Ran `terraform apply` again. The application pods became Ready, the PVC became Bound, and the website and health endpoints worked with a freshly initialised database.

This verified recreation on the existing kind cluster using the existing Flask image and local Helm chart.

## State and secrets

This lab uses local Terraform state.

`sensitive()` hides private Helm values from normal output, but they remain in state. State files, backups and saved plans must stay out of Git. Keep `.terraform.lock.hcl` in Git.

Manage this installation through Terraform to keep its configuration and state consistent.

## Cleanup

```bash
terraform plan -destroy
terraform destroy
```

Review before confirming. Destroy removes this project's Helm release, PVC and namespace, including its database storage with the lab's default storage configuration.

The original installation in namespace `default` is separate.

## Limitations

This is a local learning lab. Remote state, team collaboration and cloud infrastructure provisioning are not implemented.
