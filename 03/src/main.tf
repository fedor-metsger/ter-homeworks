resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

#    { webservers =  yandex_compute_instance.count,
#      storage =  yandex_compute_instance.disk-vm.*,
#      databases =  yandex_compute_instance.for-each    }  )
#
#output "IPAddress" {
#  value = element(virtualbox_vm.vm1.*.network_adapter.0.ipv4_address, 1)
#}

locals {
  vminfo_count = [
    for vm in yandex_compute_instance.count.* : {
      name = vm["name"],
      id = vm["id"],
      fqdn = vm["fqdn"]
    }
  ]
  vminfo_for_each = [
    for vm in yandex_compute_instance.for-each : {
       name = vm["name"]
       id = vm["id"]
       fqdn = vm["fqdn"]
    }
  ]
  vminfo_storage = [
    {
       name = yandex_compute_instance.disk-vm.name,
       id = yandex_compute_instance.disk-vm.id,
       fqdn = yandex_compute_instance.disk-vm.fqdn
    }
  ]
}

#var VMInfo "count" {
#  value = [
#    for vm in yandex_compute_instance.count.* : {
#	name = vm["name"],
#	id = vm["id"],
#	fqdn = vm["fqdn"]
#    }
#  ]
#}

#output "VMInfo_for_each" {
#  value = [
#    for vm in yandex_compute_instance.for-each : {
#       name = vm["name"]
#       id = vm["id"]
#       fqdn = vm["fqdn"]
#    }
#  ]
#}
#
#output "VMInfo_storage" {
#  value = [
#    {
#       name = yandex_compute_instance.disk-vm.name,
#       id = yandex_compute_instance.disk-vm.id,
#       fqdn = yandex_compute_instance.disk-vm.fqdn
#    }
#  ]
#}

output VMInfo {
  value = concat(local.vminfo_count, local.vminfo_for_each, local.vminfo_storage)
}
