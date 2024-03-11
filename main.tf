# main.tf
# Create a new tag
resource "digitalocean_tag" "droplet_1" {
  name = "admin"
}

# Configure the DigitalOcean provider
provider "digitalocean" {
  token = "dop_v1_981f9b04529cb9329a1b05c15976a639b9502682e94cb654a823866813f13644"
}
resource "digitalocean_ssh_key" "droplet_1" {
  name       = "Terraform-SSH"
  public_key = file("/root/.ssh/id_rsa.pub")
}
# Define a DigitalOcean Droplet
resource "digitalocean_droplet" "droplet_1" {
  name   = "controller-node-${formatdate("HHMM", timestamp())}"
  region = "blr1"
  size   = "s-2vcpu-2gb"
  image  = "centos-stream-8-x64"
  tags   = [digitalocean_tag.droplet_1.id] 
  
  # SSH key configuration
  ssh_keys = [digitalocean_ssh_key.droplet_1.fingerprint]

  # Ansible_Playbook
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.ipv4_address}, ./ansible/pre-playbook.yaml"
    working_dir = "${path.module}"
  }
}
  
# Output the IP address of the Droplet
output "droplet_ip" {
  value = digitalocean_droplet.droplet_1.ipv4_address
  
}