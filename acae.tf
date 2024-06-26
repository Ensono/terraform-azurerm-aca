resource "azurerm_container_app_environment" "container_app_env" {
  count                          = var.create_container_app_environment ? 1 : 0
  name                           = var.container_app_environment_name
  location                       = var.location
  resource_group_name            = var.create_rg ? azurerm_resource_group.container_group_rg[0].name : var.resource_group_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  infrastructure_subnet_id       = var.container_app_environment_infrastructure_subnet_id
  internal_load_balancer_enabled = var.container_app_environment_internal_load_balancer_enabled
  zone_redundancy_enabled        = var.container_app_environment_zone_redundancy_enabled

  dynamic "workload_profile" {
    for_each = var.workload_profiles
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      maximum_count         = workload_profile.value.maximum_count
      minimum_count         = workload_profile.value.minimum_count
    }
  }

  tags = var.resource_tags

  lifecycle {
    ignore_changes = [
      tags,
    ]

    precondition {
      condition     = var.container_app_environment_internal_load_balancer_enabled == null || var.container_app_environment_infrastructure_subnet_id != null
      error_message = "`var.container_app_environment_internal_load_balancer_enabled` can only be set when `var.container_app_environment_infrastructure_subnet_id` is specified."
    }
    precondition {
      condition     = var.container_app_environment_zone_redundancy_enabled == null || var.container_app_environment_infrastructure_subnet_id != null
      error_message = "`var.container_app_environment_zone_redundancy_enabled` can only be set when `var.container_app_environment_infrastructure_subnet_id` is specified."
    }
  }
}
