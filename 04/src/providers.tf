
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "bucket-for-terraform"
    region     = "ru-central1"
    key        = "terraform-tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1ge8m51046pv654acbv/etnoj5a7tvqiqh4j1bnj"
    dynamodb_table = "tfstate-lock"
  }
}


provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

