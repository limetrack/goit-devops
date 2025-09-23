variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Version of kube-prometheus-stack Helm chart"
  type        = string
  default     = "55.5.0"
}