// Add kubeconfig file as a github action secret
resource "github_actions_secret" "kubeconfig" {
  repository = var.repo_name
  secret_name = "KUBECONFIG"
  plaintext_value = file("../tmp/kubeconfig")
}

// Add registry credentials as github action secrets
resource "github_actions_secret" "registry_url" {
  repository = var.repo_name
  secret_name = "REGISTRY_URL"
  plaintext_value = var.registry_url
}

resource "github_actions_secret" "registry_username" {
  repository = var.repo_name
  secret_name = "REGISTRY_USERNAME"
  plaintext_value = var.registry_username
}

resource "github_actions_secret" "registry_password" {
  repository = var.repo_name
  secret_name = "REGISTRY_PASSWORD"
  plaintext_value = var.registry_password
}