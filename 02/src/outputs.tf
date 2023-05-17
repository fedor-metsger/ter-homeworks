
/*
output "vm_db_ip_address" {
  value = yandex_compute_instance.db_platform.network_interface[0].nat_ip_address
  description = "vm external ip"
}

output "vm_web_ip_address" {
  value = yandex_compute_instance.platform.network_interface[0].nat_ip_address
  description = "vm external ip"
}
*/

output "external_ips" {
  value = {
    "web_ip" = yandex_compute_instance.platform.network_interface[0].nat_ip_address
    "db_ip" = yandex_compute_instance.db_platform.network_interface[0].nat_ip_address
  }
}
