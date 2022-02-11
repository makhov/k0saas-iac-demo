// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "workers" {
  name         = "worker-${random_id.instance_id.hex}"
  machine_type = var.worker_machine_type
  zone         = "us-west1-a"
  project      = var.project_id
  count        = var.worker_count


  metadata = {
    ssh-keys = <<EOF
      k0sctl:${tls_private_key.k0sctl.public_key_openssh}
EOF
  }

  tags = ["worker"]

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

  network_interface {
    network = "default"
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
}
