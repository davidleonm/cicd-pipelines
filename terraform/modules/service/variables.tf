variable "hostname" {
  description = "Hostname where microk8s is running"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "sa_role" {
  description = "Service account role to execute the service"
  type        = string
}

variable "name" {
  description = "Name of the service"
  type        = string
}

variable "container_port" {
  description = "Internal port of the container"
  type        = number
}

variable "external_port" {
  description = "External port of the service"
  type        = number
}

variable "volumes" {
  description = "List of volumes to mount"

  type = list(object({
    name               = string
    storage_class_name = string
    host_path          = string
    container_path     = string
    read_only          = bool
    capacity           = string
  }))

  default = []
}

variable "config_maps" {
  description = "List of config maps to mount"

  type = list(object({
    name              = string
    content_file_path = string
    container_path    = string
    file_name         = string
  }))

  default = []
}

variable "secret_volumes" {
  description = "List of volumes to mount from secrets"

  type = list(object({
    name           = string
    secret_name    = string
    container_path = string
    read_only      = bool
  }))

  default = []
}

variable "docker_image" {
  description = "Docker image to use"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to set"
  type        = map(string)
  sensitive   = true
}

variable "security_context" {
  description = "Security context for the container"

  type = object({
    run_as_user     = optional(number)
    run_as_group    = optional(number)
    fs_group        = optional(number)
    run_as_non_root = optional(bool)
  })

  default = {}
}

variable "enable_http_probes" {
  description = "Enable probes for the service using HTTP"
  type        = bool
  default     = false
}

variable "enable_tcp_probes" {
  description = "Enable probes for the service using TCP"
  type        = bool
  default     = false
}