################################################################################
# GitOps Bridge: Private ssh keys for git
################################################################################
resource "kubernetes_namespace" "argocd" {
  depends_on = [module.eks]
  metadata {
    name = local.argocd_namespace
  }
}
resource "kubernetes_secret" "git_secrets" {
  depends_on = [kubernetes_namespace.argocd]
  for_each = {
    git-addons = {
      type                    = "git"
      url                     = local.gitops_addons_url
      githubAppID             = "977675"
      githubAppInstallationID = "54085417"
      githubAppPrivateKey     = local.github_private_key
    }
    git-fleet = {
      type                    = "git"
      url                     = local.gitops_fleet_url
      githubAppID             = "977675"
      githubAppInstallationID = "54085417"
      githubAppPrivateKey     = local.github_private_key
    }
    git-platform = {
      type                    = "git"
      url                     = local.gitops_platform_url
      githubAppID             = "977675"
      githubAppInstallationID = "54085417"
      githubAppPrivateKey     = local.github_private_key
    }
    git-workloads = {
      type                    = "git"
      url                     = local.gitops_workload_url
      githubAppID             = "977675"
      githubAppInstallationID = "54085417"
      githubAppPrivateKey     = local.github_private_key
    }
    argocd-bitnami = {
      type      = "helm"
      url       = "charts.bitnami.com/bitnami"
      name      = "Bitnami"
      enableOCI = true
    }
  }
  metadata {
    name      = each.key
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = each.value
}

# Creating parameter for argocd hub role for the spoke clusters to read
resource "aws_ssm_parameter" "argocd_hub_role" {
  name  = "/fleet-hub/argocd-hub-role"
  type  = "String"
  value = module.argocd_hub_pod_identity.iam_role_arn
}
################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source  = "gitops-bridge-dev/gitops-bridge/helm"
  version = "0.1.0"
  cluster = {
    cluster_name = module.eks.cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps
  argocd = {
    name             = "argocd"
    namespace        = local.argocd_namespace
    chart_version    = "7.4.1"
    values           = [file("${path.module}/argocd-initial-values.yaml")]
    timeout          = 600
    create_namespace = false
  }
  depends_on = [kubernetes_secret.git_secrets]
}
