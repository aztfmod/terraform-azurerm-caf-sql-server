output "object" {
  description = "Returns the full object of the created SQL Server"
  value       = azurerm_sql_server.sql_server
  sensitive   = true
}

output "name" {
  description = "Returns the name of the created SQL Server"
  value       = azurerm_sql_server.sql_server.name
}

output "id" {
  description = "Returns the ID of the created SQL Server"
  value       = azurerm_sql_server.sql_server.id
}

output "password" {
  description = "Value of the administrative password of the SQL Server - Recommended to get this output and store in AKV"
  sensitive   = true
  value       = azurerm_sql_server.sql_server.administrator_login_password
}
