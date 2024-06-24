terraform {
  backend "azurerm" {
    resource_group_name  = "ResourceGroupName"  # Name of the resource group that your storage account resides in.
    storage_account_name = "StorageAccountName" # Name of the storage account for your terraform state file.
    container_name       = "tfstate"            # What your container name within the storage account is called.
    key                  = "terraform.tfstate"  # What your state output will be named.
  }
}

provider "azurerm" {
  features {}
}
