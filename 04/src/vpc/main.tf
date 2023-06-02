
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

resource "yandex_vpc_network" "net_name" {
  name = var.env_name
}

resource "yandex_vpc_subnet" "subnet_name" {
  count = length(var.subnets)

  name           = join("-", [var.env_name, var.subnets[count.index].zone])
  zone           = var.subnets[count.index].zone
  network_id     = yandex_vpc_network.net_name.id
  v4_cidr_blocks = [var.subnets[count.index].cidr]
}
