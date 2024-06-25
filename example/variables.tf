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

variable "create_rg" {
  type        = bool
  description = "Set value whether to create a Resource group or not."
}

variable "create_container_app_environment" {
  type        = bool
  description = "Set value whether to create a Container App Environment or not."
}

variable "create_container_app" {
  type        = bool
  description = "Set value whether to create Container Apps or not."
}

variable "container_app_environment_name" {
  type        = string
  description = "Name of your Azure Container App Environment"
}

variable "container_app_name" {
  type        = string
  description = "The name of the Container App"
}

variable "container_app_ingress_target_port" {
  type        = number
  description = "The target port on the container for the Ingress traffic. All Ingress setting can be enabled when this is specified "
}

variable "container_app_ingress_external_enabled" {
  type        = bool
  description = "Enable external ingress from outside the Container App Environment. Defaults to false."
}

variable "container_app_container_max_replicas" {
  type        = number
  description = "The maximum number of replicas for the containers."
}

variable "container_app_container_min_replicas" {
  type        = number
  description = "The minimum number of replicas for the containers."
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
  description = "Set of containers for the Container App"
}
