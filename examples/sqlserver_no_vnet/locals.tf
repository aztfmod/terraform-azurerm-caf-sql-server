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
      name     = "test-caf-sqlserver"
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
      #     name                = "mypool"
      #     edition             = "Basic"
      #     dtu                 = 50
      #     db_dtu_min          = 0
      #     db_dtu_max          = 5
      #     pool_size           = 5000
    }
  }
  subnet_id_list = {}
  diagnostics    = {}
}