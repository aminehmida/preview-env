# SSH Key for VM access
resource "hcloud_ssh_key" "default" {
  name       = "default-key"
  public_key = file("../tmp/id_ed25519.pub")
}

# Hetzner Cloud Server
resource "hcloud_server" "kubernetes_server" {
  name        = var.server_name
  server_type = var.server_type
  image       = var.server_image
  location    = var.hetzner_location
  
  ssh_keys    = [hcloud_ssh_key.default.id]
  
  backups     = var.enable_backups
  
  # Basic firewall rules
  firewall_ids = [hcloud_firewall.web_firewall.id]
  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      host        = self.ipv4_address
      private_key = file("../tmp/id_ed25519")
    }
    inline = ["echo 'SSH connection is ready!'"]
  }

    provisioner "local-exec" {
      command = "pyinfra ${self.ipv4_address} deploy.py -y --ssh-user root --ssh-key ../tmp/id_ed25519"
      working_dir = "../pyinfra"
    }

}

# Firewall for the server
resource "hcloud_firewall" "web_firewall" {
  name = "web-firewall"
  
  # SSH access
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  
  # HTTP access
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  
  # HTTPS access
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # kubernetes access
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}