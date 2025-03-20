output "fully_qualified_name" {
  description = "FQDN of the service"
  value       = "${var.name}.${var.namespace}.svc.cluster.local"
}

output "container_port" {
  description = "Internal port of the container"
  value       = var.container_port
}