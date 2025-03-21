resource "kubernetes_namespace" "grafana" {
  metadata {
    name = var.grafana_namespace
  }
}

resource "helm_release" "grafana-k8s-monitoring" {
  name             = "grafana-k8s-monitoring"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "k8s-monitoring"
  namespace        = kubernetes_namespace.grafana.metadata[0].name
  create_namespace = true
  atomic           = true
  timeout          = 300

  values = [file("${path.module}/values.yaml")]

  set {
    name  = "cluster.name"
    value = var.cluster_name
  }

  set {
    name  = "destinations[0].url"
    value = var.destinations_prometheus_url
  }

  set_sensitive {
    name  = "destinations[0].auth.username"
    value = var.destinations_prometheus_username
  }

  set_sensitive {
    name  = "destinations[0].auth.password"
    value = var.grafana_token
  }

  set {
    name  = "destinations[1].url"
    value = var.destinations_loki_url
  }

  set_sensitive {
    name  = "destinations[1].auth.username"
    value = var.destinations_loki_username
  }

  set_sensitive {
    name  = "destinations[1].auth.password"
    value = var.grafana_token
  }

  set {
    name  = "destinations[2].url"
    value = var.destinations_otlp_url
  }

  set_sensitive {
    name  = "destinations[2].auth.username"
    value = var.destinations_otlp_username
  }

  set_sensitive {
    name  = "destinations[2].auth.password"
    value = var.grafana_token
  }

  set {
    name  = "destinations[3].url"
    value = var.destinations_pyroscope_url
  }

  set_sensitive {
    name  = "destinations[3].auth.username"
    value = var.destinations_pyroscope_username
  }

  set_sensitive {
    name  = "destinations[3].auth.password"
    value = var.grafana_token
  }

  set {
    name  = "alloy-metrics.remoteConfig.url"
    value = var.fleetmanagement_url
  }

  set_sensitive {
    name  = "alloy-metrics.remoteConfig.auth.username"
    value = var.fleetmanagement_username
  }

  set_sensitive {
    name  = "alloy-metrics.remoteConfig.auth.password"
    value = var.grafana_token
  }

  set {
    name  = "alloy-singleton.remoteConfig.url"
    value = var.fleetmanagement_url
  }

  set_sensitive {
    name  = "alloy-singleton.remoteConfig.auth.username"
    value = var.fleetmanagement_username
  }

  set_sensitive {
    name  = "alloy-singleton.remoteConfig.auth.password"
    value = var.grafana_token
  }

  set {
    name  = "alloy-logs.remoteConfig.url"
    value = var.fleetmanagement_url
  }

  set_sensitive {
    name  = "alloy-logs.remoteConfig.auth.username"
    value = var.fleetmanagement_username
  }

  set_sensitive {
    name  = "alloy-logs.remoteConfig.auth.password"
    value = var.grafana_token
  }

  set {
    name  = "alloy-receiver.remoteConfig.url"
    value = var.fleetmanagement_url
  }

  set_sensitive {
    name  = "alloy-receiver.remoteConfig.auth.username"
    value = var.fleetmanagement_username
  }

  set_sensitive {
    name  = "alloy-receiver.remoteConfig.auth.password"
    value = var.grafana_token
  }

  set {
    name  = "alloy-profiles.remoteConfig.url"
    value = var.fleetmanagement_url
  }

  set_sensitive {
    name  = "alloy-profiles.remoteConfig.auth.username"
    value = var.fleetmanagement_username
  }

  set_sensitive {
    name  = "alloy-profiles.remoteConfig.auth.password"
    value = var.grafana_token
  }
}