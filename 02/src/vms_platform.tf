
### VM WEB vars

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
}

/*
variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
}
*/

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
}

variable "vm_web_resources" {
  type           = map(number)
  default        = {
                     "cores" = 2,
                     "memory" = 1,
                     "core_fraction" = 5
                }
}

### VM DB vars

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
}

/*
variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
}
*/

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
}

variable "vm_db_resources" {
  type           = map(number)
  default        = {
                     "cores" = 2,
                     "memory" = 2,
                     "core_fraction" = 20
                }
}
