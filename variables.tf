############################################
# Resource Group Variables
############################################

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The location of the resource group"
}

variable "resource_tags" {
  description = "Map of tags to be applied to all resources created as part of this module"
  type        = map(string)
  default     = {}
}

#############################################
# CONDITIONAL SETTINGS
#############################################

variable "create_rg" {
  type        = bool
  default     = true
  description = "Set value whether to create a Resource group or not."
}

variable "create_container_app_environment" {
  type        = bool
  default     = false
  description = "Set value whether to create a Container App Environment or not."
}

variable "create_container_app" {
  type        = bool
  default     = false
  description = "Set value whether to create Container Apps or not."
}

############################################
# Azure Container App Environment Variables
############################################

variable "container_app_environment_name" {
  type        = string
  default     = null
  description = "Name of your Azure Container App Environment"
}

variable "container_app_environment_infrastructure_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The existing subnet to use for the container apps control plane. Changing this forces a new resource to be created."
}

variable "container_app_environment_internal_load_balancer_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. Changing this forces a new resource to be created."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "(Optional) The ID for the Log Analytics Workspace to link this Container Apps Managed Environment to. Changing this forces a new resource to be created."
}

variable "container_app_environment_zone_redundancy_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should the Container App Environment be created with Zone Redundancy enabled? Defaults to `false`. Can only be set to true if infrastructure_subnet_id is specified."
}

variable "workload_profiles" {
  type = list(object({
    name                  = string
    workload_profile_type = string
    maximum_count         = number
    minimum_count         = number
  }))
  default     = []
  description = "List of workload profiles to be created in the Container App Environment. Workload profile type for the workloads to run on. Possible values include `Consumption`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16` and `E32`."

}

###########################
# Azure Container App
##########################

variable "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  type        = string
  default     = null
}

variable "container_app_name" {
  type        = string
  description = "The name of the Container App"
  default     = null
}

variable "container_app_revision_mode" {
  type        = string
  description = "The revision mode of the Container App. Possible values include `Single` and `Multiple`"
  default     = "Single"
}

variable "container_app_workload_profile_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Workload Profile in the Container App Environment to place this Container App"
}

variable "container_app_registry" {
  type = object({
    server               = string
    username             = optional(string)
    password_secret_name = optional(string)
    identity             = optional(string)
  })
  default     = null
  description = "The registry configuration for the Container App"
}

variable "container_app_identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default     = null
  description = "The identity configuration for the Container App"
}

variable "container_app_secrets" {
  type = list(object({
    name                = string
    identity            = optional(string)
    key_vault_secret_id = optional(string)
    value               = optional(string)
  }))
  default     = null
  description = "The secrets configuration for the Container App"
}

# Container App Ingress for the Container App 

variable "container_app_ingress_target_port" {
  type        = number
  default     = null
  description = "The target port on the container for the Ingress traffic. All Ingress setting can be enabled when this is specified "
}

variable "container_app_ingress_allow_insecure_connections" {
  type        = bool
  default     = false
  description = "(Optional) Allow insecure connections for the ingress. Defaults to false."
}

variable "container_app_ingress_external_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable external ingress from outside the Container App Environment. Defaults to false."
}

variable "container_app_ingress_transport" {
  type        = string
  default     = null
  description = "(Optional) The transport method for the Ingress. Possible values are auto, http, http2 and tcp. Defaults to auto."
}

variable "container_app_ingress_exposed_port" {
  type        = number
  default     = null
  description = "(Optional) The exposed port on the container for the Ingress traffic.It can only be specified when transport is set to tcp"
}

variable "container_app_ingress_traffic_weight_label" {
  type        = string
  default     = null
  description = "(Optional) The label to apply to the revision as a name prefix for routing traffic."
}

variable "container_app_ingress_traffic_weight_latest_revision" {
  type        = bool
  default     = true
  description = "(Optional) Use the latest revision for traffic weight. Defaults to true."
}

variable "container_app_ingress_traffic_weight_revision_suffix" {
  type        = string
  default     = null
  description = "(Optional) The suffix string to which this traffic_weight applies."
}

variable "container_app_ingress_traffic_weight_percentage" {
  type        = number
  default     = 100
  description = "The percentage of traffic weight for the ingress. Defaults to 100. The percentage of traffic which should be sent this revision"
}

variable "container_app_ingress_ip_security_restrictions" {
  type = list(object({
    action           = string
    ip_address_range = list(string)
    name             = string
    description      = optional(string)
  }))
  default     = []
  description = "(Optional) List of IP security restrictions for the ingress. Each restriction can apply to multiple IP addresses or ranges. The action types in an all ip_security_restriction blocks must be the same for the ingress, mixing Allow and Deny rules is not currently supported by the service."

  validation {
    condition = alltrue([
      for restriction in var.container_app_ingress_ip_security_restrictions :
      contains(["Allow", "Deny"], restriction.action)
    ])
    error_message = "The action must be either 'Allow' or 'Deny'."
  }
}

###############################
# Azure Container App Container
###############################

variable "container_app_container_max_replicas" {
  type        = number
  default     = null
  description = "(Optional) The maximum number of replicas for the containers."
}

variable "container_app_container_min_replicas" {
  type        = number
  default     = null
  description = "(Optional) The minimum number of replicas for the containers."
}

variable "container_app_container_revision_suffix" {
  type        = string
  default     = null
  description = "The revision suffix for the containers "
}

variable "container_app_containers" {
  type = set(object({
    args    = optional(list(string))
    command = optional(list(string))
    cpu     = number
    image   = string
    name    = string
    memory  = string
    env = optional(list(object({
      name        = string
      secret_name = optional(string)
      value       = optional(string)
    })))
    volume_mounts = optional(list(object({
      name = string
      path = string
    })))
    liveness_probe = optional(object({
      failure_count_threshold = optional(number)
      header = optional(object({
        name  = string
        value = string
      }))
      host             = optional(string)
      initial_delay    = optional(number, 1)
      interval_seconds = optional(number, 10)
      path             = optional(string)
      port             = number
      timeout          = optional(number, 1)
      transport        = string
    }))
    readiness_probe = optional(object({
      failure_count_threshold = optional(number)
      header = optional(object({
        name  = string
        value = string
      }))
      host                    = optional(string)
      interval_seconds        = optional(number, 10)
      path                    = optional(string)
      port                    = number
      success_count_threshold = optional(number, 3)
      timeout                 = optional(number)
      transport               = string
    }))
    startup_probe = optional(object({
      failure_count_threshold = optional(number)
      header = optional(object({
        name  = string
        value = string
      }))
      host             = optional(string)
      interval_seconds = optional(number, 10)
      path             = optional(string)
      port             = number
      timeout          = optional(number)
      transport        = string
    }))
  }))
  default     = []
  description = "Set of containers for the Container App"
}

variable "container_app_init_containers" {
  type = set(object({
    args    = optional(list(string))
    command = optional(list(string))
    cpu     = number
    image   = string
    name    = string
    memory  = string
    env = optional(list(object({
      name        = string
      secret_name = optional(string)
      value       = optional(string)
    })))
    volume_mounts = optional(list(object({
      name = string
      path = string
    })))
  }))
  default     = []
  description = "Set of init containers for the Container App"
}

variable "container_app_container_volumes" {
  type = set(object({
    name         = string
    storage_name = optional(string)
    storage_type = optional(string)
  }))
  default     = []
  description = "Set of volumes for the Containers"
}

variable "create_custom_domain_for_container_app" {
  default     = false
  description = "Whether you want to create a custom domain for the Container App"
}

variable "custom_domain" {
  type        = bool
  default     = null
  description = "The name of the custom domain"
}

variable "custom_domain_cert" {
  type        = string
  default     = null
  description = "The Certificate Private Key as a base64 encoded PFX or PEM"
}

variable "custom_domain_cert_password" {
  type        = string
  default     = null
  description = "The password for the Certificate"
}
