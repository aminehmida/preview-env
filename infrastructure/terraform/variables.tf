# Terraform Variables

# Hetzner API token variable
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.hcloud_token) > 0
    error_message = "The Hetzner Cloud API token must not be empty."
  }
}

variable "hetzner_location" {
  description = "Hetzner Cloud server location"
  type        = string
  default     = "nbg1"  # Nuremberg, Germany
}

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
  default     = "cx22"  # 2 vCPU, 4GB RAM
}

variable "server_name" {
  description = "Name of the Hetzner Cloud server"
  type        = string
  default     = "kubernetes-server"
}

variable "server_image" {
  description = "OS image for the Hetzner Cloud server"
  type        = string
  default     = "debian-12"
}

variable "enable_backups" {
  description = "Enable backups for the Hetzner Cloud server"
  type        = bool
  default     = false
}

variable "repo_name" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "preview-env"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.cloudflare_api_token) > 0
    error_message = "The Cloudflare API token must not be empty."
  }
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  validation {
    condition     = length(var.cloudflare_zone_id) > 0
    error_message = "The Cloudflare Zone ID must not be empty."
  }
}

variable "github_token" {
  description = "GitHub API Token"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.github_token) > 0
    error_message = "The GitHub API token must not be empty."
  }
}

variable "github_owner" {
  description = "GitHub owner (username or organization)"
  type        = string
  default     = "aminehmida"
}

variable "registry_url" {
  description = "Docker registry URL"
  type        = string
}

variable "registry_username" {
  description = "Docker registry username"
  type        = string
}

variable "registry_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
}