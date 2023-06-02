# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»

1. **Приложите скриншот входящих правил "Группы безопасности" в ЛК Yandex Cloud или скриншот отказа в предоставлении доступа к preview версии.**

    Ответ:
    
![Capture28.png](https://github.com/fedor-metsger/devops-netology/blob/main/Capture28.png)

2. **Создайте файл count-vm.tf. Опишите в нем создание двух одинаковых ВМ web-1 и web-2(не web-0 и web-1!), с минимальными параметрами, используя мета-аргумент count loop. Назначьте ВМ созданную в 1-м задании группу безопасности.**

Привожу файл [count-vm.tf](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/count-vm.tf):
```
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "count" {
  count = 2
  name = "web-${count.index + 1}"

  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.example.id
    ]
  }

  metadata = {
    serial-port-enable = 1
#    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
    ssh-keys           = join(":", ["ubuntu", file("~/.ssh/id_rsa.pub")])
  }

}
```
**Создайте файл for_each-vm.tf. Опишите в нем создание 2 ВМ с именами "main" и "replica" разных по cpu/ram/disk , используя мета-аргумент for_each loop. Используйте переменную типа list(object({ vm_name=string, cpu=number, ram=number, disk=number })). При желании внесите в переменную все возможные параметры.**

Привожу файл [for_each-vm.tf](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/for_each-vm.tf):
```
resource "yandex_compute_instance" "for-each" {
  depends_on = [yandex_compute_instance.count]

  for_each = { main = {cpu=2, ram=1, fraction=20}, replica = {cpu=4, ram=2, fraction=5} }

  name = "${each.key}"

  platform_id = "standard-v1"
  resources {
    cores         = "${each.value.cpu}"
    memory        = "${each.value.ram}"
    core_fraction = "${each.value.fraction}"
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = join(":", ["ubuntu", file("~/.ssh/id_rsa.pub")])
  }

}
```
**ВМ из пункта 2.2 должны создаваться после создания ВМ из пункта 2.1.**

**Используйте функцию file в local переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ №2.**

Выполнено в приведённых выше файлах.

3. **Создайте 3 одинаковых виртуальных диска, размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле disk_vm.tf.**

**Создайте в том же файле одну ВМ c именем "storage" . Используйте блок dynamic secondary_disk{..} и мета-аргумент for_each для подключения созданных вами дополнительных дисков.**

Привожу файл [disk_vm.tf](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/disk_vm.tf):
```
resource "yandex_compute_disk" "disk" {
  count = 3
  name = "disk-${count.index + 1}"

  type     = "network-hdd"
  size = 1
}

resource "yandex_compute_instance" "disk-vm" {
  name = "storage"

  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disk
    content {
      disk_id = yandex_compute_disk.disk[secondary_disk.key].id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = join(":", ["ubuntu", file("~/.ssh/id_rsa.pub")])
  }
}
```

4. **В файле ansible.tf создайте inventory-файл для ansible. Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции. Готовый код возьмите из демонстрации к лекции demonstration2. Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2.(т.е. 5 ВМ)**

Привожу файл [ansible.tf](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/ansible.tf):
```
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl",

#    { storage =  yandex_compute_instance.disk-vm.* } )
    { webservers =  yandex_compute_instance.count,
      storage =  yandex_compute_instance.disk-vm.*,
      databases =  yandex_compute_instance.for-each    }  )

  filename = "${abspath(path.module)}/hosts.cfg"
}


resource "null_resource" "web_hosts_provision" {
#Ждем создания инстанса
depends_on = [yandex_compute_instance.count,
              yandex_compute_instance.disk-vm,
              yandex_compute_instance.for-each]

#Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  provisioner "local-exec" {
    command = "cat ~/.ssh/id_rsa | ssh-add -"
  }

#Костыль!!! Даем ВМ время на первый запуск. Лучше выполнить это через wait_for port 22 на стороне ansible
 provisioner "local-exec" {
    command = "sleep 30"
  }

#Запуск ansible-playbook
  provisioner "local-exec" {                  
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/test.yml"
    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }
    triggers = {  
      always_run         = "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
      playbook_src_hash  = file("${abspath(path.module)}/test.yml") # при изменении содержимого playbook файла
#      ssh_public_key     = var.public_key # при изменении переменной
    }

}
```

**Инвентарь должен содержать 3 группы [webservers], [databases], [storage] и быть динамическим, т.е. обработать как группу из 2-х ВМ так и 999 ВМ.**

Привожу файл [hosts.tftpl](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/hosts.tftpl):
```
[webservers]

%{~ for i in webservers ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} 

%{~ endfor ~}

[databases]

%{~ for i in databases ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} 

%{~ endfor ~}

[storage]

%{~ for i in storage ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} 

%{~ endfor ~}
```

**Выполните код. Приложите скриншот получившегося файла.**

Привожу файл [hosts.cfg](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/hosts.cfg):
```
[webservers]
web-1   ansible_host=158.160.59.128 
web-2   ansible_host=51.250.7.197 

[databases]
main   ansible_host=158.160.96.57 
replica   ansible_host=158.160.38.247 

[storage]
storage   ansible_host=158.160.52.129 
```

5. **Приложите скриншот вывода команды terrafrom output**

```
fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/03/src$ terraform output
VMInfo = [
  {
    "fqdn" = "fhm5kja3f8hnbsl0brf7.auto.internal"
    "id" = "fhm5kja3f8hnbsl0brf7"
    "name" = "web-1"
  },
  {
    "fqdn" = "fhm2djgk9ds6tdl69nbg.auto.internal"
    "id" = "fhm2djgk9ds6tdl69nbg"
    "name" = "web-2"
  },
  {
    "fqdn" = "fhmhlmi2fujqtautqshr.auto.internal"
    "id" = "fhmhlmi2fujqtautqshr"
    "name" = "main"
  },
  {
    "fqdn" = "fhm378lv203ah80crpcs.auto.internal"
    "id" = "fhm378lv203ah80crpcs"
    "name" = "replica"
  },
  {
    "fqdn" = "fhmaoc02cq0mnes7233a.auto.internal"
    "id" = "fhmaoc02cq0mnes7233a"
    "name" = "storage"
  },
]
fedor@fedor-Z68P-DS3:~/CODE/Netology/DevOps/ter-homeworks/03/src$
```
6. **Используя null_resource и local-exec примените ansible-playbook к ВМ из ansible inventory файла. Готовый код возьмите из демонстрации к лекции demonstration2.**

Привожу файл [ansible.tf](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/ansible.tf):
```
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl",

#    { storage =  yandex_compute_instance.disk-vm.* } )
    { webservers =  yandex_compute_instance.count,
      storage =  yandex_compute_instance.disk-vm.*,
      databases =  yandex_compute_instance.for-each    }  )

  filename = "${abspath(path.module)}/hosts.cfg"
}


resource "null_resource" "web_hosts_provision" {
#Ждем создания инстанса
depends_on = [yandex_compute_instance.count,
              yandex_compute_instance.disk-vm,
              yandex_compute_instance.for-each]

#Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  provisioner "local-exec" {
    command = "cat ~/.ssh/id_rsa | ssh-add -"
  }

#Костыль!!! Даем ВМ время на первый запуск. Лучше выполнить это через wait_for port 22 на стороне ansible
 provisioner "local-exec" {
    command = "sleep 30"
  }

#Запуск ansible-playbook
  provisioner "local-exec" {                  
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/test.yml"
    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }
    triggers = {  
      always_run         = "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
      playbook_src_hash  = file("${abspath(path.module)}/test.yml") # при изменении содержимого playbook файла
#      ssh_public_key     = var.public_key # при изменении переменной
    }

}
```

   **Дополните файл шаблон hosts.tftpl. Формат готового файла:**
    `netology-develop-platform-web-0   ansible_host="<внешний IP-address или внутренний IP-address если у ВМ отсутвует внешний адрес>"`
    
Привожу файл [hosts.tftpl](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03/03/src/hosts.tftpl):
```
[webservers]

%{~ for i in webservers ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} 

%{~ endfor ~}

[databases]

%{~ for i in databases ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} 

%{~ endfor ~}

[storage]

%{~ for i in storage ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} 

%{~ endfor ~}
```
 
   **Для проверки работы уберите у ВМ внешние адреса. Этот вариант используется при работе через bastion сервер.**
   
Убрал параметр **nat** (перевёл в **false**). Изменённый код выложил в отдельную [terraform-03-no_nat](https://github.com/fedor-metsger/ter-homeworks/tree/terraform-03-no_nat/03/src)

Привожу файл [hosts.tftpl](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03-no_nat/03/src/hosts.tftpl):
```
[webservers]

%{~ for i in webservers ~}
%{if i["network_interface"][0]["nat"]}
${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"]}
%{else}
${i["name"]} ansible_host=${i["network_interface"][0]["ip_address"]}
%{ endif }
%{~ endfor ~}

[databases]

%{~ for i in databases ~}
%{if i["network_interface"][0]["nat"]}
${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"]}
%{else}
${i["name"]} ansible_host=${i["network_interface"][0]["ip_address"]}
%{ endif }
%{~ endfor ~}

[storage]

%{~ for i in storage ~}
%{if i["network_interface"][0]["nat"]}
${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"]}
%{else}
${i["name"]} ansible_host=${i["network_interface"][0]["ip_address"]}
%{ endif }
%{~ endfor ~}
```
А так же файл [hosts.cfg](https://github.com/fedor-metsger/ter-homeworks/blob/terraform-03-no_nat/03/src/hosts.cfg):
```
[webservers]

web-1 ansible_host=10.0.1.32

web-2 ansible_host=10.0.1.20

[databases]

main ansible_host=10.0.1.12

replica ansible_host=10.0.1.3

[storage]

storage ansible_host=10.0.1.9
```
