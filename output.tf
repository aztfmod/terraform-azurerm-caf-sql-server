output "object" {
  value = azurerm_sql_server.sql_server
  sensitive = true
}

output "name" {
  value = azurerm_sql_server.sql_server.name
}

output "id" {
  value = azurerm_sql_server.sql_server.id
}

output "password" {
  description = "Value of the administrative password of the SQL Server - Recommended to get this output and store in AKV"
  sensitive = true
  value = azurerm_sql_server.sql_server.administrator_login_password
}
