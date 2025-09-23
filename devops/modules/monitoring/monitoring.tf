resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = var.namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version
  create_namespace = false

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.monitoring]
}