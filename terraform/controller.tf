resource "google_compute_instance" "controller" {
  name         = "controller-${random_id.instance_id.hex}"
  machine_type = var.controller_machine_type
  zone         = "us-west1-a"
  project      = var.project_id

  metadata = {
    ssh-keys = <<EOF
      k0sctl:${tls_private_key.k0sctl.public_key_openssh}
EOF
  }

  count = var.controller_count

  tags = ["controller"]

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  metadata_startup_script = "mkdir -p /var/lib/k0s/manifests && chmod 0777 /var/lib/k0s/manifests"

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  provisioner "file" {
    source      = "files/argocd"
    destination = "/var/lib/k0s/manifests"

    connection {
      type        = "ssh"
      user        = "k0sctl"
      private_key = tls_private_key.k0sctl.private_key_pem
      host        = google_compute_instance.controller[count.index].network_interface[0].access_config[0].nat_ip
    }
  }
}