terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }

  required_version = ">= 0.14"
}

resource "tls_private_key" "k0sctl" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "gcp_private_pem" {
  file_permission = "600"
  filename        = format("%s/%s", path.module, "gcp_private.pem")
  content         = tls_private_key.k0sctl.private_key_pem
}

locals {
  k0s_tmpl = {
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "cluster"
    spec = {
      hosts = [
      for host in concat(google_compute_instance.controller, google_compute_instance.workers) : {
        ssh = {
          address = host.network_interface[0].access_config[0].nat_ip
          user    = "k0sctl"
          keyPath = "./gcp_private.pem"
        }
        role = tolist(host.tags)[0]
      }
      ]
      k0s = {
        version = "v1.23.3+k0s.0"
      }
    }
  }
}

output "k0s_cluster" {
  value = yamlencode(local.k0s_tmpl)
}