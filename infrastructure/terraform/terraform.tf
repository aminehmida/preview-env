terraform {
  required_version = ">= 1.12"
    required_providers {
        hcloud = {
            source  = "hetznercloud/hcloud"
            version = "~> 1.52"
        }
        cloudflare = {
            source  = "cloudflare/cloudflare"
            version = "~> 5.7"
        }
        github = {
            source  = "integrations/github"
            version = "~> 6.0"
        }
    }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Configure the Cloudflare Provider
provider "cloudflare" {
    api_token = var.cloudflare_api_token
}

# Configure the GitHub Provider
provider "github" {
    token = var.github_token
    owner = var.github_owner
}