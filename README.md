# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

1. **Создайте 1 ВМ, используя данный модуль. В файле cloud-init.yml необходимо использовать переменную для ssh ключа вместо хардкода. Передайте ssh-ключ в функцию template_file в блоке vars ={} .**
   **Воспользуйтесь примером. Обратите внимание что ssh-authorized-keys принимает в себя список, а не строку!**

   **Добавьте в файл cloud-init.yml установку nginx.**
   
   Привожу файл [cloud-init.yml](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-04/04/src/cloud-init.yml):

   ```
   #cloud-config
   users:
     - name: ubuntu
       groups: sudo
       shell: /bin/bash
       sudo: ['ALL=(ALL) NOPASSWD:ALL']
       ssh-authorized-keys:
         - ${ssh_public_key}
   package_update: true
   package_upgrade: false
   packages:
     - vim
     - nginx
   ```

   **Предоставьте скриншот подключения к консоли и вывод команды** `sudo nginx -t`
   
   ```
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ ssh ubuntu@51.250.73.175
   The authenticity of host '51.250.73.175 (51.250.73.175)' can't be established.
   ED25519 key fingerprint is SHA256:GkoDpnz53dS4GfPysge0t6XFFTPE+iEdV1CAuxf3xYc.
   This key is not known by any other names
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added '51.250.73.175' (ED25519) to the list of known hosts.
   Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-149-generic x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage

   The programs included with the Ubuntu system are free software;
   the exact distribution terms for each program are described in the
   individual files in /usr/share/doc/*/copyright.

   Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
   applicable law.

   To run a command as administrator (user "root"), use "sudo <command>".
   See "man sudo_root" for details.

   ubuntu@develop-web-0:~$ nginx -t

   Command 'nginx' not found, but can be installed with:

   sudo apt install nginx-core    # version 1.18.0-0ubuntu1.4, or
   sudo apt install nginx-extras  # version 1.18.0-0ubuntu1.4
   sudo apt install nginx-full    # version 1.18.0-0ubuntu1.4
   sudo apt install nginx-light   # version 1.18.0-0ubuntu1.4

   ubuntu@develop-web-0:~$
   ```

2. **Напишите локальный модуль vpc, который будет создавать 2 ресурса: одну сеть и одну подсеть в зоне, объявленной при вызове модуля. например: ru-central1-a.**
   
   **Модуль должен возвращать значения vpc.id и subnet.id**
   
   Прилагаю ссылку на модуль: [vpc](https://github.com/fedor-metsger/ter-homeworks/tree/terraform-04/04/src/vpc)

   **Замените ресурсы yandex_vpc_network и yandex_vpc_subnet, созданным модулем.**
   
   Прилагаю файл [main.tf](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-04/04/src/main.tf):
   ```
   module "vpc" {
     source    = "./vpc"
     env_name  = "develop"
     zone      = "ru-central1-a"
     cidr      = "10.0.1.0/24"
   }

   module "test-vm" {
     source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
     env_name        = "develop"
     network_id      = module.vpc.vpc_id
     subnet_zones    = ["ru-central1-a"]
     subnet_ids      = [ module.vpc.subnet_id ]
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
   ```

   **Сгенерируйте документацию к модулю с помощью terraform-docs.**
   
   Прилагаю вывод **terraform-docs**:
   
   ------------------------------------------------
   ## Requirements

   | Name | Version |
   |------|---------|
   | <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13 |

   ## Providers

   | Name | Version |
   |------|---------|
   | <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.92.0 |

   ## Modules

   No modules.

   ## Resources

   | Name | Type |
   |------|------|
   | [yandex_vpc_network.net_name](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
   | [yandex_vpc_subnet.subnet_name](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |
   
   ## Inputs

   | Name | Description | Type | Default | Required |
   |------|-------------|------|---------|:--------:|
   | <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `string` | `"10.0.0.0/24"` | no |
   | <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name | `string` | `"develop"` | no |
   | <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC network&subnet name | `string` | `"develop"` | no |
   | <a name="input_zone"></a> [zone](#input\_zone) | https://cloud.yandex.ru/docs/overview/concepts/geo-scope | `string` | `"ru-central1-a"` | no |

   ## Outputs

   | Name | Description |
   |------|-------------|
   | <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
   | <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |

------------------------------------------

3. **Выведите список ресурсов в стейте.**

   **Удалите из стейта модуль vpc.**

   **Импортируйте его обратно. Проверьте terraform plan - изменений быть не должно. Приложите список выполненных команд и вывод.**
   
   Прилагаю вывод команд:
   
   ```
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform state list
   data.template_file.userdata
   module.test-vm.data.yandex_compute_image.my_image
   module.test-vm.yandex_compute_instance.vm[0]
   module.vpc.yandex_vpc_network.net_name
   module.vpc.yandex_vpc_subnet.subnet_name
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform state show module.vpc.yandex_vpc_network.net_name
   \# module.vpc.yandex_vpc_network.net_name:
   resource "yandex_vpc_network" "net_name" {
       created_at = "2023-06-02T14:02:58Z"
       folder_id  = "b1go2coto23a6o9qniv9"
       id         = "enpjchrqk9unqff5gajr"
       labels     = {}
       name       = "develop"
       subnet_ids = []
   }
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform state show module.vpc.yandex_vpc_subnet.subnet_name
   \# module.vpc.yandex_vpc_subnet.subnet_name:
   resource "yandex_vpc_subnet" "subnet_name" {
    created_at     = "2023-06-02T14:02:58Z"
    folder_id      = "b1go2coto23a6o9qniv9"
    id             = "e9b4go0gvvkq6q8plbf0"
    labels         = {}
    name           = "develop-ru-central1-a"
    network_id     = "enpjchrqk9unqff5gajr"
    v4_cidr_blocks = [
        "10.0.1.0/24",
    ]
    v6_cidr_blocks = []
    zone           = "ru-central1-a"
   }
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform state rm 'module.vpc'
   Removed module.vpc.yandex_vpc_network.net_name
   Removed module.vpc.yandex_vpc_subnet.subnet_name
   Successfully removed 2 resource instance(s).
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform import module.vpc.yandex_vpc_network.net_name enpjchrqk9unqff5gajr
   data.template_file.userdata: Reading...
   data.template_file.userdata: Read complete after 0s [id=a188abb0daeef04def27c9164c98402a79667f6164cd2816a7b9664d4afba9a1]
   module.vpc.yandex_vpc_network.net_name: Importing from ID "enpjchrqk9unqff5gajr"...
   module.vpc.yandex_vpc_network.net_name: Import prepared!
     Prepared yandex_vpc_network for import
   module.vpc.yandex_vpc_network.net_name: Refreshing state... [id=enpjchrqk9unqff5gajr]
   module.test-vm.data.yandex_compute_image.my_image: Reading...
   module.test-vm.data.yandex_compute_image.my_image: Read complete after 2s [id=fd8lape4adm5melne14m]

   Import successful!

   The resources that were imported are shown above. These resources are now in
   your Terraform state and will henceforth be managed by Terraform.

   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform import module.vpc.yandex_vpc_subnet.subnet_name e9b4go0gvvkq6q8plbf0
   data.template_file.userdata: Reading...
   data.template_file.userdata: Read complete after 0s [id=a188abb0daeef04def27c9164c98402a79667f6164cd2816a7b9664d4afba9a1]
   module.test-vm.data.yandex_compute_image.my_image: Reading...
   module.vpc.yandex_vpc_subnet.subnet_name: Importing from ID "e9b4go0gvvkq6q8plbf0"...
   module.vpc.yandex_vpc_subnet.subnet_name: Import prepared!
     Prepared yandex_vpc_subnet for import
   module.vpc.yandex_vpc_subnet.subnet_name: Refreshing state... [id=e9b4go0gvvkq6q8plbf0]
   module.test-vm.data.yandex_compute_image.my_image: Read complete after 2s [id=fd8lape4adm5melne14m]

   Import successful!

   The resources that were imported are shown above. These resources are now in
   your Terraform state and will henceforth be managed by Terraform.

   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform plan
   module.test-vm.data.yandex_compute_image.my_image: Reading...
   data.template_file.userdata: Reading...
   module.vpc.yandex_vpc_network.net_name: Refreshing state... [id=enpjchrqk9unqff5gajr]
   data.template_file.userdata: Read complete after 0s [id=a188abb0daeef04def27c9164c98402a79667f6164cd2816a7b9664d4afba9a1]
   module.test-vm.data.yandex_compute_image.my_image: Read complete after 2s [id=fd8lape4adm5melne14m]
   module.vpc.yandex_vpc_subnet.subnet_name: Refreshing state... [id=e9b4go0gvvkq6q8plbf0]
   module.test-vm.yandex_compute_instance.vm[0]: Refreshing state... [id=fhm5mc92ioq0pk5bu04u]

   No changes. Your infrastructure matches the configuration.

   Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$
   ```

4. **Измените модуль vpc так, чтобы он мог создать подсети во всех зонах доступности, переданных в переменной типа list(object) при вызове модуля.**

   **Предоставьте код, план выполнения, результат из консоли YC.**
   
   Привожу код в [отдельной ветке](https://github.com/fedor-metsger/ter-homeworks/tree/terraform-04-add/04/src).
   
   Привожу скриншоты с YC:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Capture29.png)
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Capture30.png)
   
   План выполнения:
   ```
   module.test-vm.data.yandex_compute_image.my_image: Reading...
   data.template_file.userdata: Reading...
   data.template_file.userdata: Read complete after 0s [id=a188abb0daeef04def27c9164c98402a79667f6164cd2816a7b9664d4afba9a1]
   module.test-vm.data.yandex_compute_image.my_image: Read complete after 3s [id=fd8lape4adm5melne14m]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # module.test-vm.yandex_compute_instance.vm[0] will be created
         + resource "yandex_compute_instance" "vm" {
         + allow_stopping_for_update = true
         + created_at                = (known after apply)
         + description               = "TODO: description; {{terraform managed}}"
         + folder_id                 = (known after apply)
         + fqdn                      = (known after apply)
         + gpu_cluster_id            = (known after apply)
         + hostname                  = "develop-web-0"
         + id                        = (known after apply)
         + labels                    = {
             + "env"     = "develop"
             + "project" = "undefined"
           }
         + metadata                  = {
             + "serial-port-enable" = "1"
             + "user-data"          = <<-EOT
                   #cloud-config
                   users:
                     - name: ubuntu
                       groups: sudo
                       shell: /bin/bash
                       sudo: ['ALL=(ALL) NOPASSWD:ALL']
                       ssh-authorized-keys:
                            - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmAQm4S2bJ8BP+Cj+9JNcAQcGhhieeYwcxglNJN7+zDvZhg/7PsxcdYWKcwuQEP6Eu7LylGyKIoMMM1nJ/xojJx6p4mkMbNZI239Bkju5+pej0OJSCPTZjMTsOp0RkGmeMuvFEE89MsGCU1hf6AZwBR5Jtn4SrHS5GAXwxgNA6zK/BcI7fhNflhMIcfvBYq1+y/s5f6EniUTMtijIW3aWVr4rdWKsznlTkQpPlI2Rr6Qzy5OsoS2gk0+rFD2V7rzVe9Djplp5taxqVY1oA0MpoqM10gQoxaY12GIK0WElMMjFzeysV21IdI345015tTmXxS2EVryUrWsS4BryhbnansDUgihI1Sr5kKeEeK9d3Wqi6uFDcDwizB3Cne7dr0RpT+7gpbvTMyM6AB1ON3MrE28GDUNjTlaEgRyRvYynIx/bEVIO+XvBDUt2oQdG7dbGPcWppfjkAkJsVcfSRamwSEoD0c5BmJAcp9ez70rUME5n3WUhuWrpbcehY1jMv58M= fedor@DESKTOP-FEKCCDN
                
                   package_update: true
                   package_upgrade: false
                   packages:
                     - vim
                     - nginx
               EOT
           }
         + name                      = "develop-web-0"
         + network_acceleration_type = "standard"
         + platform_id               = "standard-v1"
         + service_account_id        = (known after apply)
         + status                    = (known after apply)
         + zone                      = "ru-central1-a"

         + boot_disk {
             + auto_delete = true
             + device_name = (known after apply)
             + disk_id     = (known after apply)
             + mode        = (known after apply)
   
             + initialize_params {
                 + block_size  = (known after apply)
                 + description = (known after apply)
                 + image_id    = "fd8lape4adm5melne14m"
                 + name        = (known after apply)
                 + size        = 10
                 + snapshot_id = (known after apply)
                 + type        = "network-hdd"
               }
           }
   
         + network_interface {
             + index              = (known after apply)
             + ip_address         = (known after apply)
             + ipv4               = true
             + ipv6               = (known after apply)
             + ipv6_address       = (known after apply)
             + mac_address        = (known after apply)
             + nat                = true
             + nat_ip_address     = (known after apply)
             + nat_ip_version     = (known after apply)
             + security_group_ids = (known after apply)
             + subnet_id          = (known after apply)
           }

         + resources {
             + core_fraction = 5
             + cores         = 2
             + memory        = 1
           }

         + scheduling_policy {
             + preemptible = true
           }
       }

     # module.vpc_dev.yandex_vpc_network.net_name will be created
     + resource "yandex_vpc_network" "net_name" {
         + created_at                = (known after apply)
         + default_security_group_id = (known after apply)
         + folder_id                 = (known after apply)
         + id                        = (known after apply)
         + labels                    = (known after apply)
         + name                      = "develop"
         + subnet_ids                = (known after apply)
       }

     # module.vpc_dev.yandex_vpc_subnet.subnet_name[0] will be created
     + resource "yandex_vpc_subnet" "subnet_name" {
         + created_at     = (known after apply)
         + folder_id      = (known after apply)
         + id             = (known after apply)
         + labels         = (known after apply)
         + name           = "develop-ru-central1-a"
         + network_id     = (known after apply)
         + v4_cidr_blocks = [
             + "10.0.1.0/24",
           ]
         + v6_cidr_blocks = (known after apply)
         + zone           = "ru-central1-a"
       }

     # module.vpc_prod.yandex_vpc_network.net_name will be created
     + resource "yandex_vpc_network" "net_name" {
         + created_at                = (known after apply)
         + default_security_group_id = (known after apply)
         + folder_id                 = (known after apply)
         + id                        = (known after apply)
         + labels                    = (known after apply)
         + name                      = "production"
         + subnet_ids                = (known after apply)
       }

     # module.vpc_prod.yandex_vpc_subnet.subnet_name[0] will be created
     + resource "yandex_vpc_subnet" "subnet_name" {
         + created_at     = (known after apply)
         + folder_id      = (known after apply)
         + id             = (known after apply)
         + labels         = (known after apply)
         + name           = "production-ru-central1-a"
         + network_id     = (known after apply)
         + v4_cidr_blocks = [
             + "10.0.1.0/24",
           ]
         + v6_cidr_blocks = (known after apply)
         + zone           = "ru-central1-a"
     }

     # module.vpc_prod.yandex_vpc_subnet.subnet_name[1] will be created
       + resource "yandex_vpc_subnet" "subnet_name" {
       + created_at     = (known after apply)
       + folder_id      = (known after apply)
       + id             = (known after apply)
       + labels         = (known after apply)
       + name           = "production-ru-central1-b"
       + network_id     = (known after apply)
       + v4_cidr_blocks = [
           + "10.0.2.0/24",
         ]
       + v6_cidr_blocks = (known after apply)
       + zone           = "ru-central1-b"
     }

     # module.vpc_prod.yandex_vpc_subnet.subnet_name[2] will be created
     + resource "yandex_vpc_subnet" "subnet_name" {
         + created_at     = (known after apply)
         + folder_id      = (known after apply)
         + id             = (known after apply)
         + labels         = (known after apply)
         + name           = "production-ru-central1-c"
         + network_id     = (known after apply)
         + v4_cidr_blocks = [
             + "10.0.3.0/24",
           ]
         + v6_cidr_blocks = (known after apply)
         + zone           = "ru-central1-c"
     }

   Plan: 7 to add, 0 to change, 0 to destroy.
   ```
   
6. **Разверните у себя локально vault, используя docker-compose.yml в проекте.**
   
   **Для входа в web интерфейс и авторизации terraform в vault используйте токен "education"**
   **Создайте новый секрет по пути http://127.0.0.1:8200/ui/vault/secrets/secret/create   
   Path: example
   secret data key: test secret data value: congrats!**
   
   **Считайте данный секрет с помощью terraform и выведите его в output**
   
   Привожу модуль [vault]()
   
   Привожу вывод команды:
   ```
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$ terraform output
   vault_secret = tomap({
     "test" = "congrats!"
   })
   fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/04/src$
   ```
   
   **Попробуйте самостоятельно разобраться в документации и записать новый секрет в vault с помощью terraform.**
   
   Привожу скриншот из консоли **Vault**:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Capture31.png)
   
   
   
