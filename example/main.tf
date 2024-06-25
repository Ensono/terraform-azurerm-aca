module "container_app" {
  source = "../"

  # Resource Group
  resource_group_name = var.resource_group_name
  location            = var.location

  # Conditional Settings
  create_container_app             = var.create_container_app
  create_container_app_environment = var.create_container_app_environment
  create_rg                        = var.create_rg

  # Container App Environment
  container_app_environment_name = var.container_app_environment_name

  # Container App
  container_app_name                   = var.container_app_name
  container_app_container_max_replicas = var.container_app_container_max_replicas
  container_app_container_min_replicas = var.container_app_container_min_replicas
  container_app_containers             = var.container_app_containers

  # #  Ingress configuration
  container_app_ingress_external_enabled = var.container_app_ingress_external_enabled
  container_app_ingress_target_port      = var.container_app_ingress_target_port

}

