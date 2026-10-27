# Choose the namespace for the Terraform-managed installation.
variable "namespace" {
  description = "Namespace for the Flask and PostgreSQL lab"
  type        = string
  default     = "terraform-lab"
}

# Locate the Helm chart on this machine.
variable "chart_path" {
  description = "Path to the Flask Helm chart"
  type        = string
  default     = "~/k8s-helm-flask-app/flask-app"
}

# Locate the private Helm values file outside the repository.
variable "private_values_path" {
  description = "Path to the private Helm  values file"
  type        = string
  default     = "~/devops-lab-private.yaml"
}
