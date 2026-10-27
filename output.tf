# Display the namespace managed by this project.
output "namespace" {
  description = "Application namespace"
  value       = kubernetes_namespace_v1.lab.metadata[0].name
}

# Display the installed Helm release name.
output "release_name" {
  description = "Helm release name"
  value       = helm_release.flask_app.name
}

#Provide a command to access the application from this VM.
output "port_forward" {
  description = "Run this command to access the application"
  value       = "kubectl port-forward -n ${kubernetes_namespace_v1.lab.metadata[0].name} service/flask-app 9091:8081"
}
