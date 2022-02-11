variable "project_id" {
  type    = string
}

variable "cluster_name" {
  type    = string
  default = "k0sctl"
}

// TODO: switch to alpine
variable "os_image" {
  type    = string
  default = "debian-cloud/debian-9"
}

variable "controller_count" {
  type    = number
  default = 1
}

variable "worker_count" {
  type    = number
  default = 1
}

variable "controller_machine_type" {
  type    = string
  default = "f1-micro"
}

variable "worker_machine_type" {
  type    = string
  default = "f1-micro"
}