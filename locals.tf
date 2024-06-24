locals {
  flattened_ip_security_restrictions = flatten([
    for restriction in var.container_app_ingress_ip_security_restrictions : [
      for ip_range in restriction.ip_address_range : {
        action           = restriction.action
        ip_address_range = ip_range
        name             = length(restriction.ip_address_range) > 1 ? "${restriction.name}-${index(restriction.ip_address_range, ip_range)}" : restriction.name
        description      = restriction.description
      }
    ]
  ])
}
