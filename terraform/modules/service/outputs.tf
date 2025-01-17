output "service_name" {
  description = "Name of the service"
  value       = kubernetes_service.service.metadata[0].name
}