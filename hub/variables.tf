variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "kms_key_admin_roles" {
  description = "list of role ARNs to add to the KMS policy"
  type        = list(string)
  default     = []
}

variable "env_config" {
  description = "Map of objects for per environment configuration"
  type = map(object({
    account_id = string
  }))
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = true
    enable_metrics_server               = true
    enable_external_secrets             = true
    enable_kyverno                      = false
    enable_karpenter                    = true
    enable_argocd                       = true
  }
}

variable "enable_addon_selector" {
  description = "select addons using cluster selector"
  type        = bool
  default     = false
}
