
# Create the namespace selected by the input variable.
resource "kubernetes_namespace_v1" "lab" {
  metadata {
    name = var.namespace
  }
}

# Request persistent storage for PostgreSQL in that namespace.
resource "kubernetes_persistent_volume_claim_v1" "postgres" {
  metadata {
    name = "postgres-data"

    # Reference the namespace so Terraform creates it first.
    namespace = kubernetes_namespace_v1.lab.metadata[0].name
  }

  spec {
    # Allow the volume to be mounted read/write by a single node.
    access_modes = ["ReadWriteOnce"]

    # Use the existing kind cluster's storage provisioner.
    storage_class_name = "standard"

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }

  # Binding waits for a   consumning Pod, so let Terraform continue.
  wait_until_bound = false
}


# Install the existing Flask/PostgreSQL chart in our separate namespace.
resource "helm_release" "flask_app" {
  name      = "flask-app"
  namespace = kubernetes_namespace_v1.lab.metadata[0].name
  #Expand the configured chart path to an absolute path.
  chart = pathexpand(var.chart_path)

  # Load private values and hide them from normal Terraform output.
  values = [
    sensitive(file(pathexpand(var.private_values_path)))
  ]

  # Wait for the application's resources to become ready.
  wait    = true
  timeout = 300

  # Create the storage claim before installing PostgreSQL.
  depends_on = [
    kubernetes_persistent_volume_claim_v1.postgres
  ]
}
