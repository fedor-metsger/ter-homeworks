
output "vpc_id" {
  value = yandex_vpc_network.net_name.id
}

/*
locals {
  subnet_ids = [
    for sn in yandex_vpc_subnet.subnet_name.* : sn.id
  ]
}
*/

output subnet_ids {
  value = [
    for sn in yandex_vpc_subnet.subnet_name.* : sn.id
  ]
#  value = local.subnet_ids
}
