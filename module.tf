# June 2020 implemented from 
# https://www.terraform.io/docs/providers/azurerm/r/sql_server.html 
# https://www.terraform.io/docs/providers/azurerm/r/sql_virtual_network_rule.html
# https://www.terraform.io/docs/providers/azurerm/r/sql_active_directory_administrator.html
# https://www.terraform.io/docs/providers/azurerm/r/sql_elasticpool.html 

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "azurecaf_naming_convention" "sql" {

  name          = var.sql_server.name
  prefix        = var.prefix
  resource_type = "azurerm_sql_server"
  convention    = var.convention
}

resource "azurerm_sql_server" "sql_server" {

  name                         = azurecaf_naming_convention.sql.result
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = var.sql_server.version
  administrator_login          = var.sql_server.admin
  administrator_login_password = lookup(var.sql_server, "password", random_password.password.result)
  tags                         = local.tags
  connection_policy            = lookup(var.sql_server, "connection_policy", null)

  dynamic "identity" {
    for_each = lookup(var.sql_server, "identity", {}) != {} ? [1] : []
    
    content {
     type = var.sql_server.identity.type
    }
  }

  dynamic "extended_auditing_policy" {
    for_each = lookup(var.sql_server, "extended_auditing_policy", {}) != {} ? [1] : []
    
    content {
     storage_account_access_key  = var.sql_server.extended_auditing_policy.storage_account_access_key
     storage_endpoint = var.sql_server.extended_auditing_policy.storage_endpoint
     storage_account_access_key_is_secondary = lookup(var.sql_server.extended_auditing_policy, "storage_account_access_key_is_secondary", null)
     retention_in_days = lookup(var.sql_server.extended_auditing_policy, "retention_in_days", null)
    }
  }
}

resource "azurerm_sql_virtual_network_rule" "sql_vnet_rule" {
  ## create only if we have a non-empty subnet ID passed
  for_each = var.subnet_id_list

  name                = substr(basename(each.value), 0,63)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sql_server.name
  subnet_id           = each.value
}

resource "azurerm_sql_active_directory_administrator" "admins" {
  ## create only if the aad_admin is non-empty
  count = var.aad_admin != {} ? 1 : 0

  server_name         = azurerm_sql_server.sql_server.name
  resource_group_name = var.resource_group_name
  login               = var.aad_admin.name
  object_id           = var.aad_admin.id
  tenant_id           = var.aad_admin.tenant_id
}

resource "azurerm_sql_elasticpool" "sql_server_elastic_pool" {
  ## create only if elastic_pool object is filled
  for_each            = var.sql_server.elastic_pool
  ## dependencies in order for changes not to be concurrent on the object and get an error
  depends_on          = [azurerm_sql_virtual_network_rule.sql_vnet_rule, azurerm_sql_active_directory_administrator.admins ]

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.sql_server.name
  edition             = each.value.edition
  dtu                 = each.value.dtu
  db_dtu_min          = each.value.db_dtu_min
  db_dtu_max          = each.value.db_dtu_max
  pool_size           = each.value.pool_size
}
