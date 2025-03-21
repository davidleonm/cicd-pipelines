resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "grafana"
  }
}