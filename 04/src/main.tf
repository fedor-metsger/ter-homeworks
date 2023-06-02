/*
module "vpc" {
  source    = "./vpc"
  env_name  = "develop"
  zone      = "ru-central1-a"
  cidr      = "10.0.1.0/24"
}
*/

module "vpc_prod" {
  source       = "./vpc"
  env_name     = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-c", cidr = "10.0.3.0/24" },
  ]
}

module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}

module "test-vm" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name        = "develop"
#  network_id      = yandex_vpc_network.develop.id
  network_id      = module.vpc_dev.vpc_id
  subnet_zones    = ["ru-central1-a"]
  subnet_ids      = module.vpc_dev.subnet_ids
  instance_name   = "web"
  instance_count  = 1
  image_family    = "ubuntu-2004-lts"
  public_ip       = true
  
  metadata = {
    user-data          = data.template_file.userdata.rendered
    serial-port-enable = 1
  }
}

data template_file "userdata" {
  template = file("${path.module}/cloud-init.yml")

  vars = {
    ssh_public_key = file("~/.ssh/id_rsa.pub")
  }
}
