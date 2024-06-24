output "container_rg_name" {
  description = "The name of the created RG"
  value       = var.create_rg ? azurerm_resource_group.container_group_rg[0].name : null
}

output "container_app_environment_id" {
  description = "The ID of the created Container Apps Environment"
  value       = var.create_container_app_environment ? azurerm_container_app_environment.container_app_env[0].id : null
}

output "container_app_environment_name" {
  description = "The name of the created Container Apps Environment"
  value       = var.create_container_app_environment ? azurerm_container_app_environment.container_app_env[0].name : null
}

output "container_app_name" {
  description = "The name of the created Container App"
  value       = var.create_container_app ? azurerm_container_app.container_app[0].name : null
}

output "container_app_id" {
  description = "The ID of the created Container App"
  value       = var.create_container_app ? azurerm_container_app.container_app[0].id : null
}

output "container_app_fqdn" {
  description = "The FQDN of the created Container App"
  value       = var.create_container_app ? azurerm_container_app.container_app[0].ingress[0].fqdn : null
}
