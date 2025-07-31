# Terraform Outputs

output "server_ip" {
  description = "The public IP address of the Hetzner server"
  value       = hcloud_server.kubernetes_server.ipv4_address
}

output "server_ip_v6" {
  description = "The public IPv6 address of the Hetzner server"
  value       = hcloud_server.kubernetes_server.ipv6_address
}