terraform {
  experiments = [variable_validation]
}

provider "azurerm" {
  features {}

  subscription_id = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"

}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}
