provider "azurerm" {
   features {}
}

resource "azurerm_resource_group" "rg_test" {
  name     = local.resource_groups.test.name
  location = local.resource_groups.test.location
  tags     = local.tags
}

module "la_test" {
  source  = "aztfmod/caf-log-analytics/azurerm"
  version = "2.1.0"
 
  convention          = local.convention
  location            = local.location
  name                = local.name_la
  solution_plan_map   = local.solution_plan_map 
  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.rg_test.name
  tags                = local.tags
}

module "diags_test" {
  source  = "aztfmod/caf-diagnostics-logging/azurerm"
  version = "2.0.1"
 
  name                  = local.name_diags
  convention            = local.convention
  resource_group_name   = azurerm_resource_group.rg_test.name
  prefix                = local.prefix
  location              = local.location
  tags                  = local.tags
  enable_event_hub      = local.enable_event_hub
}

data "azurerm_storage_account" "diagnostics_storage" {
  name                = basename(module.diags_test.diagnostics_map.diags_sa)
  resource_group_name = azurerm_resource_group.rg_test.name
}

data "azurerm_client_config" "current" {
}

module "sql_server_demo" {
  source  = "../.."

  prefix                      = local.prefix
  tags                        = local.tags
  convention                  = local.convention

  resource_group_name         = azurerm_resource_group.rg_test.name
  location                    = local.location
  sql_server                  = local.sql_server
  subnet_id                   = local.subnet_id
  aad_admin                   = local.aad_admin

  diagnostics_map             = module.diags_test.diagnostics_map
  log_analytics_workspace     = module.la_test
  diagnostics_settings        = local.diagnostics
}


