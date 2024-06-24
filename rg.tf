resource "azurerm_resource_group" "container_group_rg" {
  count    = var.create_rg ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.resource_tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
