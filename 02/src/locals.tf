
locals {
  vm_web_name = "${var.project}-${var.vpc_name}-platform-web"
  vm_db_name = "${var.project}-${var.vpc_name}-platform-db"
  metadata  = {
              serial-port-enable = 1,
              ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
