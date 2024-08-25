provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = [
        "eks",
        "get-token",
        "--cluster-name", module.eks.cluster_name,
        "--region", local.region,
        "--role-arn", "arn:aws:iam::${local.account_config.account_id}:role/cross-account-role"
      ]
    }
  }
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = [
      "eks",
      "get-token",
      "--cluster-name", module.eks.cluster_name,
      "--region", local.region,
      "--role-arn", "arn:aws:iam::${local.account_config.account_id}:role/cross-account-role"
    ]
  }
}

provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${local.account_config.account_id}:role/cross-account-role"
    session_name = "cross-account"
  }
}

provider "aws" {
  alias  = "shared-services"
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${local.shared_services_account.account_id}:role/cross-account-role"
    session_name = "shared-shervices"
  }
}


terraform {
  backend "s3" {}
}

