terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.1"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
  required_version = "~> 1.5.7"
}
