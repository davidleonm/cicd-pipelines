locals {
  probe_url                   = "/health"
  probe_initial_delay_seconds = 30
  probe_period_seconds        = 300
  probe_failure_threshold     = 3
  probe_timeout_seconds       = 10
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "${var.name}-sa"
    namespace = var.namespace
  }
}

resource "kubernetes_role_binding" "pod_executor_binding" {
  metadata {
    name      = "${var.sa_role}-${kubernetes_service_account.service_account.metadata[0].name}-binding"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = var.sa_role
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    type       = "NodePort"
    cluster_ip = null

    port {
      port        = var.container_port
      target_port = var.container_port
      node_port   = var.external_port
      protocol    = "TCP"
    }

    selector = {
      app = var.name
    }
  }
}

resource "kubernetes_persistent_volume" "pv" {
  for_each = { for vol in var.volumes : vol.name => vol }

  metadata {
    name = "${var.name}-${each.value.name}"
  }

  spec {
    storage_class_name               = each.value.storage_class_name
    persistent_volume_reclaim_policy = "Retain"
    access_modes                     = [each.value.read_only ? "ReadOnlyOnce" : "ReadWriteOnce"]
    volume_mode                      = "Filesystem"

    capacity = {
      storage = each.value.capacity
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = [var.hostname]
          }
        }
      }
    }

    persistent_volume_source {
      local {
        path = each.value.host_path
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  for_each = { for vol in var.volumes : vol.name => vol }

  metadata {
    name      = "${var.name}-${each.value.name}"
    namespace = var.namespace
  }

  spec {
    access_modes       = [each.value.read_only ? "ReadOnlyOnce" : "ReadWriteOnce"]
    storage_class_name = each.value.storage_class_name
    volume_mode        = "Filesystem"
    volume_name        = kubernetes_persistent_volume.pv[each.value.name].metadata[0].name

    resources {
      requests = {
        storage = each.value.capacity
      }
    }
  }

  wait_until_bound = false
}

resource "kubernetes_config_map" "config_map" {
  for_each = { for cm in var.config_maps : cm.name => cm }

  metadata {
    name      = each.key
    namespace = var.namespace
  }

  data = {
    (each.value.file_name) = file(each.value.content_file_path)
  }
}

resource "kubernetes_stateful_set" "statefulset" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    service_name = var.name
    replicas     = 1

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        service_account_name = kubernetes_service_account.service_account.metadata[0].name
        restart_policy       = "Always"

        security_context {
          run_as_user     = var.security_context.run_as_user
          run_as_group    = var.security_context.run_as_group
          fs_group        = var.security_context.fs_group
          run_as_non_root = var.security_context.run_as_non_root
        }

        container {
          name              = var.name
          image             = var.docker_image
          image_pull_policy = "Always"

          port {
            container_port = var.container_port
            protocol       = "TCP"
          }

          dynamic "volume_mount" {
            for_each = { for vol in var.volumes : vol.name => vol }

            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.container_path
            }
          }

          dynamic "volume_mount" {
            for_each = { for cm in var.config_maps : cm.name => cm }

            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.container_path
              sub_path   = volume_mount.value.file_name
            }
          }

          dynamic "volume_mount" {
            for_each = { for secret in var.secret_volumes : secret.name => secret }

            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.container_path
              read_only  = volume_mount.value.read_only
            }
          }

          dynamic "env" {
            for_each = var.environment_variables

            content {
              name  = env.key
              value = env.value
            }
          }

          liveness_probe {
            http_get {
              path = local.probe_url
              port = var.container_port
            }

            initial_delay_seconds = local.probe_initial_delay_seconds
            period_seconds        = local.probe_period_seconds
            failure_threshold     = local.probe_failure_threshold
            timeout_seconds       = local.probe_timeout_seconds
          }

          readiness_probe {
            http_get {
              path = local.probe_url
              port = var.container_port
            }

            initial_delay_seconds = local.probe_initial_delay_seconds
            period_seconds        = local.probe_period_seconds
            failure_threshold     = local.probe_failure_threshold
            timeout_seconds       = local.probe_timeout_seconds
          }
        }

        dynamic "volume" {
          for_each = { for vol in var.volumes : vol.name => vol }

          content {
            name = volume.value.name

            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.pvc[volume.value.name].metadata[0].name
            }
          }
        }

        dynamic "volume" {
          for_each = { for cm in var.config_maps : cm.name => cm }

          content {
            name = volume.value.name

            config_map {
              name = volume.value.name
            }
          }
        }

        dynamic "volume" {
          for_each = { for secret in var.secret_volumes : secret.name => secret }

          content {
            name = volume.value.name

            secret {
              secret_name = volume.value.secret_name
            }
          }
        }
      }
    }
  }
}