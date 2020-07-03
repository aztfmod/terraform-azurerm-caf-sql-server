terraform {
  experiments = [variable_validation]
}

provider "azurerm" {
  features {}
}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}
