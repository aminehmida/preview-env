# Create catch all DNS record for the preview environment
resource "cloudflare_dns_record" "catch_all" {
    zone_id = var.cloudflare_zone_id
    name    = "*.previewenv"
    content = hcloud_server.kubernetes_server.ipv4_address
    type    = "A"
    ttl     = 1
    proxied = false
}