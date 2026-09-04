terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.68.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.23.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket       = "vankata-terraform-state-bucket"
    key          = "hetzner/ivanpashkulev.com/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "hcloud" {}

provider "cloudflare" {}
