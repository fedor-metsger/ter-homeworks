###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

###common vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "your_ssh_ed25519_key"
  description = "ssh-keygen -t ed25519"
}

###example vm_web var
variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "example vm_web_ prefix"
}

###example vm_db var
variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "example vm_db_ prefix"
}

variable "ipv4_addr" {
  type    = string
  default = "192.168.0.1"
#  default = "1920.1680.0.1"
  description = "ip-адрес"

  validation {
    condition     = can(cidrhost(join("/", [var.ipv4_addr, 32]), 0))
    error_message = "Invalid IPv4 address."
  }
}

variable "ipv4_addr_list" {
  type    = list(string)
#  default = ["192.168.0.1", "1.1.1.1", "127.0.0.1"]
  default = ["192.168.0.1", "1.1.1.1", "1270.0.0.1"]
  description = "список ip-адресов"

  validation {
    condition = alltrue([
      for a in var.ipv4_addr_list : can(cidrhost(join("/", [a, 32]), 0))
    ])
    error_message = "All elements must be valid IPv4 addresses."
  }
}
