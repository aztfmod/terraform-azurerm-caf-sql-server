# **READ ME**

Thanks for your interest in Cloud Adoption Framework for Azure landing zones on Terraform.
This module is now deprecated and no longer maintained. 

As part of Cloud Adoption Framework landing zones for Terraform, we have migrated to a single module model, which you can find here: https://github.com/aztfmod/terraform-azurerm-caf and on the Terraform registry: https://registry.terraform.io/modules/aztfmod/caf/azurerm 

In Terraform 0.13 you can now call directly submodules easily with the following syntax:
```hcl
module "caf_mssql_server" {
  source  = "aztfmod/caf/azurerm//modules/databases/mssql_server"
  version = "0.4.18"
  # insert the 12 required variables here
}
```


[![VScodespaces](https://img.shields.io/endpoint?url=https%3A%2F%2Faka.ms%2Fvso-badge)](https://online.visualstudio.com/environments/new?name=terraform-azurerm-caf-sql-server&repo=aztfmod/terraform-azurerm-caf-sql-server)
[![Gitter](https://badges.gitter.im/aztfmod/community.svg)](https://gitter.im/aztfmod/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# Creates an Azure SQL Server

Creates an Azure SQL Server with:

* SQL Server
* SQL Server Elastic pool
* SQL Server Administrator
* SQL Server Azure AD Administrators
* Firewall: Restrict SQL Server to specific virtual subnets
* Diagnostics logging for SQL Server


Reference the module to a specific version (recommended):
```hcl
module "sql_server" {
    source  = "aztfmod/caf-sql-server/azurerm"
    version = "0.x.y"

    prefix                      = local.prefix
    tags                        = local.tags
    convention                  = local.convention

    resource_group_name         = azurerm_resource_group.rg_test.name
    location                    = local.location
    sql_server                  = local.sql_server
    subnet_id_list              = local.subnet_id_list
    aad_admin                   = local.aad_admin

    diagnostics_map             = module.diags_test.diagnostics_map
    log_analytics_workspace     = module.la_test
    diagnostics_settings        = local.diagnostics
}
```

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| azurecaf | n/a |
| azurerm | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aad\_admin | (Optional) Azure AD object to use as SQL Server administrator. | `map` | `{}` | no |
| convention | (Required) Naming convention to be used (check at the naming convention module for possible values). | `string` | `"cafrandom"` | no |
| diagnostics\_map | (Required) contains the SA and EH details for operations diagnostics. | `any` | n/a | yes |
| diagnostics\_settings | (Required) Map with the diagnostics settings. See the required structure in the following example or in the CAF diagnostics module documentation. | `any` | n/a | yes |
| location | (Required) Specifies the Azure location to deploy the resource. Changing this forces a new resource to be created. | `string` | n/a | yes |
| log\_analytics\_workspace | (Required) contains the log analytics workspace details for operations diagnostics. | `any` | n/a | yes |
| max\_length | (Optional) You can speficy a maximum length to the name of the resource. | `string` | `"60"` | no |
| postfix | (Optional) You can use a postfix to the name of the resource. | `string` | `""` | no |
| prefix | (Optional) You can use a prefix to the name of the resource. | `string` | `""` | no |
| resource\_group\_name | (Required) Name of the resource group where to create the resource. Changing this forces a new resource to be created. | `string` | n/a | yes |
| sql\_server | (Required) SQL Server Configuration object, see Parameters section below. | `any` | n/a | yes |
| subnet\_id\_list | (Optional) List of subnet identifiers for the resource to be created. | `map(string)` | `{}` | no |
| tags | (Required) map of tags for the deployment. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Returns the ID of the created SQL Server |
| name | Returns the name of the created SQL Server |
| object | Returns the full object of the created SQL Server |
| password | Value of the administrative password of the SQL Server - Recommended to get this output and store in AKV |

<!--- END_TF_DOCS --->

## Parameters

### sql_server
(Required) SQL Server configuration object, and SQL Elastic Pool configuration settings.

```hcl
variable "sql_server"{
    description = "(Required) SQL Server Configuration object"
    # type = object
    # ({
    #     name    = string
    #     version = string
    #     admin   = string
    #
    #     #optional fields
    #     password = string ##if not specified, password will be generated by random
    #     connection_policy = string
    #     extended_auditing_policy = object({
    #         storage_account_access_key  = string
    #         storage_endpoint            = string
    #         retention_in_days           = number
    #     })
    #     elastic_pool = object({
    #         name                = string
    #         edition             = string
    #         dtu                 = number
    #         db_dtu_min          = number
    #         db_dtu_max          = number
    #         pool_size           = number
    #     })
    # })

}
```

Example

```hcl
sql_server = {
        name = "caf_sql_test"
        version = "12.0"
        admin = "test"
        extended_auditing_policy = {
            storage_account_access_key  = data.azurerm_storage_account.diagnostics_storage.primary_access_key
            storage_endpoint            = data.azurerm_storage_account.diagnostics_storage.primary_blob_endpoint
            retention_in_days           = 60
        }
        elastic_pool = {
            name                = "mypool"
            edition             = "Basic"
            dtu                 = 50
            db_dtu_min          = 0
            db_dtu_max          = 5
            pool_size           = 5000
        }
    }
```

### aad_admin

(Optional) Object containing the Azure AD for the SQL Server admin account

```hcl
variable "aad_admin"{
    description = "(Optional) Object containing the Azure AD for the SQL Server admin account"
    # type = object({
    #     name        = string #The login name of the principal to set as the server administrator
    #     id          = string #The ID of the principal to set as the server administrator
    #     tenant_id   = string #The Azure Tenant ID
    # })
}
```

Example

```hcl
aad_admin = {
        name        = "sqladmin"
        tenant_id   = data.azurerm_client_config.current.tenant_id
        id          = data.azurerm_client_config.current.client_id
    }
```

### diagnostics_settings
(Required) Map with the diagnostics settings for object to be deployed.
See the required structure in the following example or in the diagnostics module documentation.

```hcl
variable "diagnostics_settings" {
 description = "(Required) Map with the diagnostics settings for public virtual network deployment"
}
```

Example

```hcl
diagnostics_settings = {
    log = [
                # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
                ["VMProtectionAlerts", true, true, 60],
        ]
    metric = [
                #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
                  ["AllMetrics", true, true, 60],
    ]
}
```
