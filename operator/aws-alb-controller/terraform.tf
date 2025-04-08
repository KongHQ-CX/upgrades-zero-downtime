provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "Test"
      Owner       = "nowhere@konghq.com"
      Delete-Me   = "YES"
      Terraform   = "https://github.com/KongHQ-CX/code-hm-custom"
    }
  }
}

provider "kubernetes" {
  config_context = "sample-tf-hybrid-data-plane"

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "sample-tf-hybrid-data-plane"]
  }
}

provider "helm" {
  kubernetes {
    config_context = "sample-tf-hybrid-data-plane"

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", "sample-tf-hybrid-data-plane"]
    }
  }
}
