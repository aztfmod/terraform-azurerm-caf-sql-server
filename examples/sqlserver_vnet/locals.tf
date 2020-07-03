locals {
  convention       = "cafrandom"
  name             = "caftest-sqlserver"
  name_la          = "caftestlavalid"
  name_diags       = "caftestdiags"
  location         = "southeastasia"
  prefix           = ""
  postfix          = ""
  max_length       = 60
  enable_event_hub = false
  resource_groups = {
    test = {
      name     = "test-caf-sqlserver-vnet"
      location = "southeastasia"
    },
  }
  tags = {
    environment = "DEV"
    owner       = "CAF"
  }
  solution_plan_map = {
    NetworkMonitoring = {
      "publisher" = "Microsoft"
      "product"   = "OMSGallery/NetworkMonitoring"
    },
  }
  sql_server = {
    name    = "caf_sql_test"
    version = "12.0"
    admin   = "test"

    extended_auditing_policy = {
      storage_account_access_key = data.azurerm_storage_account.diagnostics_storage.primary_access_key
      storage_endpoint           = data.azurerm_storage_account.diagnostics_storage.primary_blob_endpoint
      retention_in_days          = 60
    }
    elastic_pool = {
      pool1 = {
        name       = "mypool"
        edition    = "Basic"
        dtu        = 50
        db_dtu_min = 0
        db_dtu_max = 5
        pool_size  = 5000
      }
    }
  }
  aad_admin = {
    sqladmin = {
      name      = "sqladmin"
      tenant_id = data.azurerm_client_config.current.tenant_id
      id        = data.azurerm_client_config.current.client_id
    }
  }
  diagnostics = {}
  subnet_id_list = {
    subnet1 = data.azurerm_subnet.vnet_test.id
  }
  vnet_config = {
    vnet = {
      name          = "TestVnetSQL"
      address_space = ["10.0.0.0/25", "192.168.0.0/24"]
      dns           = ["192.168.0.16", "192.168.0.64"]
    }
    specialsubnets = {}
    subnets = {
      subnet1 = {
        name              = "SQL"
        cidr              = ["10.0.0.64/26"]
        service_endpoints = ["Microsoft.Sql"]
        nsg_name          = "SQL_nsg"
        nsg = [
          {
            name                       = "SQL",
            priority                   = "100"
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "TCP"
            source_port_range          = "*"
            destination_port_range     = "1433"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
          }
        ]
      }
    }
    diagnostics = {
      log = [
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["VMProtectionAlerts", true, true, 60],
      ]
      metric = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["AllMetrics", true, true, 60],
      ]
    }
  }
}