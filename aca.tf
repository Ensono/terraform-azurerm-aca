resource "azurerm_container_app" "container_app" {
  count                        = var.create_container_app ? 1 : 0
  container_app_environment_id = var.create_container_app_environment ? azurerm_container_app_environment.container_app_env[0].id : var.container_app_environment_id
  name                         = var.container_app_name
  resource_group_name          = var.create_rg ? azurerm_resource_group.container_group_rg[0].name : var.resource_group_name
  revision_mode                = var.container_app_revision_mode
  tags                         = var.resource_tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
  workload_profile_name = var.container_app_workload_profile_name

  template {
    max_replicas    = var.container_app_container_max_replicas
    min_replicas    = var.container_app_container_min_replicas
    revision_suffix = var.container_app_container_revision_suffix

    dynamic "container" {
      for_each = var.container_app_containers

      content {
        cpu     = container.value.cpu
        image   = container.value.image
        memory  = container.value.memory
        name    = container.value.name
        args    = container.value.args
        command = container.value.command

        dynamic "env" {
          for_each = container.value.env == null ? [] : container.value.env

          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }
        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts == null ? [] : container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe == null ? [] : [container.value.liveness_probe]

          content {
            port                    = liveness_probe.value.port
            transport               = liveness_probe.value.transport
            failure_count_threshold = liveness_probe.value.failure_count_threshold
            host                    = liveness_probe.value.host
            initial_delay           = liveness_probe.value.initial_delay
            interval_seconds        = liveness_probe.value.interval_seconds
            path                    = liveness_probe.value.path
            timeout                 = liveness_probe.value.timeout

            dynamic "header" {
              for_each = liveness_probe.value.header == null ? [] : [liveness_probe.value.header]

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe == null ? [] : [container.value.readiness_probe]

          content {
            port                    = readiness_probe.value.port
            transport               = readiness_probe.value.transport
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            host                    = readiness_probe.value.host
            interval_seconds        = readiness_probe.value.interval_seconds
            path                    = readiness_probe.value.path
            success_count_threshold = readiness_probe.value.success_count_threshold
            timeout                 = readiness_probe.value.timeout

            dynamic "header" {
              for_each = readiness_probe.value.header == null ? [] : [readiness_probe.value.header]

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
        dynamic "startup_probe" {
          for_each = container.value.startup_probe == null ? [] : [container.value.startup_probe]

          content {
            port                    = startup_probe.value.port
            transport               = startup_probe.value.transport
            failure_count_threshold = startup_probe.value.failure_count_threshold
            host                    = startup_probe.value.host
            interval_seconds        = startup_probe.value.interval_seconds
            path                    = startup_probe.value.path
            timeout                 = startup_probe.value.timeout

            dynamic "header" {
              for_each = startup_probe.value.header == null ? [] : [startup_probe.value.header]

              content {
                name  = header.value.name
                value = header.value.name
              }
            }
          }
        }
      }
    }
    dynamic "init_container" {
      for_each = var.container_app_init_containers
      content {
        args    = init_container.value.args
        command = init_container.value.command
        cpu     = init_container.value.cpu
        image   = init_container.value.image
        memory  = init_container.value.memory
        name    = init_container.value.name

        dynamic "env" {
          for_each = init_container.value.env == null ? [] : init_container.value.env
          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }
        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts == null ? [] : init_container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }
    dynamic "volume" {
      for_each = var.container_app_container_volumes
      content {
        name         = volume.value.name
        storage_name = volume.value.storage_name
        storage_type = volume.value.storage_type
      }
    }
  }
  dynamic "identity" {
    for_each = var.container_app_identity == null ? [] : [var.container_app_identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  dynamic "ingress" {
    for_each = var.container_app_ingress_target_port != null ? [1] : []

    content {
      target_port                = var.container_app_ingress_target_port
      allow_insecure_connections = var.container_app_ingress_allow_insecure_connections
      external_enabled           = var.container_app_ingress_external_enabled
      transport                  = var.container_app_ingress_transport
      exposed_port               = var.container_app_ingress_exposed_port

      traffic_weight {
        percentage      = var.container_app_ingress_traffic_weight_percentage
        label           = var.container_app_ingress_traffic_weight_label
        latest_revision = var.container_app_ingress_traffic_weight_latest_revision
        revision_suffix = var.container_app_ingress_traffic_weight_revision_suffix
      }

      dynamic "ip_security_restriction" {
        for_each = local.flattened_ip_security_restrictions

        content {
          action           = ip_security_restriction.value.action
          ip_address_range = ip_security_restriction.value.ip_address_range
          name             = ip_security_restriction.value.name
          description      = ip_security_restriction.value.description
        }
      }
    }
  }
  dynamic "registry" {
    for_each = var.container_app_registry == null ? [] : [var.container_app_registry]

    content {
      server               = registry.value.server
      identity             = registry.value.identity
      password_secret_name = registry.value.password_secret_name
      username             = registry.value.username
    }
  }
  dynamic "secret" {
    for_each = var.container_app_secrets == null ? [] : var.container_app_secrets
    content {
      name                = secret.value.name
      identity            = secret.value.identity
      key_vault_secret_id = secret.value.key_vault_secret_id
      value               = secret.value.value
    }
  }
}

resource "azurerm_container_app_custom_domain" "app" {
  count                                    = var.create_custom_domain_for_container_app ? 1 : 0
  name                                     = var.custom_domain
  container_app_id                         = azurerm_container_app.container_app[0].id
  container_app_environment_certificate_id = azurerm_container_app_environment_certificate.main.id
  certificate_binding_type                 = "SniEnabled"
}

resource "azurerm_container_app_environment_certificate" "main" {
  name                         = var.custom_domain
  container_app_environment_id = var.create_container_app_environment ? azurerm_container_app_environment.container_app_env[0].id : var.container_app_environment_id
  certificate_blob_base64      = var.custom_domain_cert
  certificate_password         = var.custom_domain_cert_password
}
