variable "grafana_namespace" {
  description = "Namespace where Grafana is installed"
  type        = string
}

variable "grafana_token" {
  description = "Token to connect to grafana"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  type    = string
  default = "microk8s"
}

variable "destinations_prometheus_url" {
  type    = string
  default = "https://prometheus-prod-24-prod-eu-west-2.grafana.net/api/prom/push"
}

variable "destinations_prometheus_username" {
  type    = string
  default = "2337443"
}

variable "destinations_loki_url" {
  type    = string
  default = "https://logs-prod-012.grafana.net/loki/api/v1/push"
}

variable "destinations_loki_username" {
  type    = string
  default = "1164399"
}

variable "destinations_otlp_url" {
  type    = string
  default = "https://tempo-prod-10-prod-eu-west-2.grafana.net:443"
}

variable "destinations_otlp_username" {
  type    = string
  default = "1158713"
}

variable "destinations_pyroscope_url" {
  type    = string
  default = "https://profiles-prod-002.grafana.net:443"
}

variable "destinations_pyroscope_username" {
  type    = string
  default = "1206602"
}

variable "fleetmanagement_url" {
  type    = string
  default = "https://fleet-management-prod-011.grafana.net"
}

variable "fleetmanagement_username" {
  type    = string
  default = "1206602"
}