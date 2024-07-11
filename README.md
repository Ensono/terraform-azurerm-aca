<!-- BEGIN_TF_DOCS -->
# Terraform-AzureRM-ACA
DESCRIPTION:
---
Bootstraps the Azure Container App. 

Will be used within the provisioned pipeline for your application depending on the options you chose.


PREREQUISITES:
---
**Azure Subscription**
  - *Service Principal* (SPN)
    - Terraform will use this to perform the authentication for the API calls
    - You will need the `client_id, subscription_id, client_secret, tenant_id`
    - Bash Example:

      ```shell 
      export ARM_CLIENT_ID=xxxx \
             ARM_CLIENT_SECRET=yyyyy \
             ARM_SUBSCRIPTION_ID=yyyyy \
             ARM_TENANT_ID=yyyyy
      ```
    - PowerShell Example:

      ```shell 
      $ARM_CLIENT_ID=xxxx
      $ARM_CLIENT_SECRET=yyyyy
      $ARM_SUBSCRIPTION_ID=yyyyy
      $ARM_TENANT_ID=yyyyy
      ```


**Terraform Backend**
  - Resource group (can be manually created for the terraform remote state)
  - Blob storage container within a storage account for the remote state management
  - Ensure you have set up your `backend.tf` file within your root directory (where you are using this module) unless you wish your terraform state to remain local.
    - **IMPORTANT: Ensure you are putting this in your .gitignore to ensure you are not passing sensitive values into your repositories!!**
  - Example TF Backend File:

    ```hcl
    terraform {
      backend "azurerm" {
        resource_group_name  = "ResourceGroupName"  # Name of the resource group that your storage account resides in.
        storage_account_name = "StorageAccountName" # Name of the storage account for your terraform state file.
        container_name       = "tfstate"            # What your container name within the storage account is called.
        key                  = "terraform.tfstate"  # What your state output will be named.
      }
    }
    ```
USAGE:
---

To activate the terraform backend for running locally we need to initialise the SPN with env vars to ensure you are running the same way as the pipeline that will ultimately be running any incremental changes.
### **1. Create your `terraform.tfvars` file**

To get up and running locally you will want to create  a `terraform.tfvars` file. 

**Important: See the below instructions for more details on the content of your terraform.tfvars file and what the impact when running the module**

For the most basic Azure Container App set up, use the below `terraform.tfvars` set up. 

- **PowerShell Example:**

```shell
# Define your variables
$TFVAR_CONTENTS = @'
create_rg                        = true
resource_group_name              = "my-aca-rg"
location                         = "uksouth"
create_container_app_environment = true
container_app_environment_name   = "my-aca-env"
create_container_app             = true
container_app_name               = "my-nginx-app"
container_app_containers = [
  {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }
]
container_app_ingress_target_port      = 80
container_app_ingress_external_enabled = true
container_app_container_max_replicas   = 10
container_app_container_min_replicas   = 1
'@

# Write the content to a file
$TFVAR_CONTENTS | Set-Content -Path "terraform.tfvars"
```
- **Bash Example:**

```shell
# Define your variables
TFVAR_CONTENTS='''
create_rg                        = true
resource_group_name              = "my-aca-rg"
location                         = "uksouth"
create_container_app_environment = true
container_app_environment_name   = "my-aca-env"
create_container_app             = true
container_app_name               = "my-nginx-app"
container_app_containers = [
  {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }
]
container_app_ingress_target_port      = 80
container_app_ingress_external_enabled = true
container_app_container_max_replicas   = 5
container_app_container_min_replicas   = 1

'''
# Write the content to a file
$TFVAR_CONTENTS > terraform.tfvars
```

### **2. Initialize your container**

- Ensure you are running the below terminal commands in the directory that contain the files you wish to emulate within the container.
    

Then you can initialize your container (if you wish to use containers, ensure you have docker desktop)
  - **Bash Example**

    ```shell
    docker run -it --rm -v $(pwd):/opt/tf-lib amidostacks/ci-tf:latest /bin/bash
    ```

  - **PowerShell Example**

    ```shell
    docker run -it --rm -v ${PWD}:/app amidostacks/runner-pwsh:0.4.60-stable pwsh
    ```

### **3. Export your authorization Credentials OR Login via Az CLI**
- **Bash Example:**

  ```shell 
  export ARM_CLIENT_ID=xxxx \
         ARM_CLIENT_SECRET=yyyyy \
         ARM_SUBSCRIPTION_ID=yyyyy \
         ARM_TENANT_ID=yyyyy
  ```

- **PowerShell Example:**

  ```shell
  $ARM_CLIENT_ID=xxxx
  $ARM_CLIENT_SECRET=yyyyy
  $ARM_SUBSCRIPTION_ID=yyyyy
  $ARM_TENANT_ID=yyyyy
  ```

- **Az CLI Example:**

  ```shell
  az login
  ```

### **4. Run your Terraform Commands**

```shell
terraform init # To initialize terraform backend, and pull down required modules.
terraform plan # To check against your state file to see what is required to add to your environment.
terraform apply # To plan and apply your configuration changes to your environment.
```

## Example Usage

Please refer to the sub folders under `examples` folder. You can provide `terraform.tfvars` and  execute `terraform apply` command in `examples`'s sub folder to try the module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.108.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.108.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |
| [azurerm_container_app_environment.container_app_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_resource_group.container_group_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_container_max_replicas"></a> [container\_app\_container\_max\_replicas](#input\_container\_app\_container\_max\_replicas) | (Optional) The maximum number of replicas for the containers. | `number` | `null` | no |
| <a name="input_container_app_container_min_replicas"></a> [container\_app\_container\_min\_replicas](#input\_container\_app\_container\_min\_replicas) | (Optional) The minimum number of replicas for the containers. | `number` | `null` | no |
| <a name="input_container_app_container_revision_suffix"></a> [container\_app\_container\_revision\_suffix](#input\_container\_app\_container\_revision\_suffix) | The revision suffix for the containers | `string` | `null` | no |
| <a name="input_container_app_container_volumes"></a> [container\_app\_container\_volumes](#input\_container\_app\_container\_volumes) | Set of volumes for the Containers | <pre>set(object({<br>    name         = string<br>    storage_name = optional(string)<br>    storage_type = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_container_app_containers"></a> [container\_app\_containers](#input\_container\_app\_containers) | Set of containers for the Container App | <pre>set(object({<br>    args    = optional(list(string))<br>    command = optional(list(string))<br>    cpu     = number<br>    image   = string<br>    name    = string<br>    memory  = string<br>    env = optional(list(object({<br>      name        = string<br>      secret_name = optional(string)<br>      value       = optional(string)<br>    })))<br>    volume_mounts = optional(list(object({<br>      name = string<br>      path = string<br>    })))<br>    liveness_probe = optional(object({<br>      failure_count_threshold = optional(number)<br>      header = optional(object({<br>        name  = string<br>        value = string<br>      }))<br>      host             = optional(string)<br>      initial_delay    = optional(number, 1)<br>      interval_seconds = optional(number, 10)<br>      path             = optional(string)<br>      port             = number<br>      timeout          = optional(number, 1)<br>      transport        = string<br>    }))<br>    readiness_probe = optional(object({<br>      failure_count_threshold = optional(number)<br>      header = optional(object({<br>        name  = string<br>        value = string<br>      }))<br>      host                    = optional(string)<br>      interval_seconds        = optional(number, 10)<br>      path                    = optional(string)<br>      port                    = number<br>      success_count_threshold = optional(number, 3)<br>      timeout                 = optional(number)<br>      transport               = string<br>    }))<br>    startup_probe = optional(object({<br>      failure_count_threshold = optional(number)<br>      header = optional(object({<br>        name  = string<br>        value = string<br>      }))<br>      host             = optional(string)<br>      interval_seconds = optional(number, 10)<br>      path             = optional(string)<br>      port             = number<br>      timeout          = optional(number)<br>      transport        = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | The ID of the Container App Environment | `string` | `null` | no |
| <a name="input_container_app_environment_infrastructure_subnet_id"></a> [container\_app\_environment\_infrastructure\_subnet\_id](#input\_container\_app\_environment\_infrastructure\_subnet\_id) | (Optional) The existing subnet to use for the container apps control plane. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_container_app_environment_internal_load_balancer_enabled"></a> [container\_app\_environment\_internal\_load\_balancer\_enabled](#input\_container\_app\_environment\_internal\_load\_balancer\_enabled) | (Optional) Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. Changing this forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_container_app_environment_name"></a> [container\_app\_environment\_name](#input\_container\_app\_environment\_name) | Name of your Azure Container App Environment | `string` | `null` | no |
| <a name="input_container_app_environment_zone_redundancy_enabled"></a> [container\_app\_environment\_zone\_redundancy\_enabled](#input\_container\_app\_environment\_zone\_redundancy\_enabled) | (Optional) Should the Container App Environment be created with Zone Redundancy enabled? Defaults to `false`. Can only be set to true if infrastructure\_subnet\_id is specified. | `bool` | `null` | no |
| <a name="input_container_app_identity"></a> [container\_app\_identity](#input\_container\_app\_identity) | The identity configuration for the Container App | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_container_app_ingress_allow_insecure_connections"></a> [container\_app\_ingress\_allow\_insecure\_connections](#input\_container\_app\_ingress\_allow\_insecure\_connections) | (Optional) Allow insecure connections for the ingress. Defaults to false. | `bool` | `false` | no |
| <a name="input_container_app_ingress_exposed_port"></a> [container\_app\_ingress\_exposed\_port](#input\_container\_app\_ingress\_exposed\_port) | (Optional) The exposed port on the container for the Ingress traffic.It can only be specified when transport is set to tcp | `number` | `null` | no |
| <a name="input_container_app_ingress_external_enabled"></a> [container\_app\_ingress\_external\_enabled](#input\_container\_app\_ingress\_external\_enabled) | (Optional) Enable external ingress from outside the Container App Environment. Defaults to false. | `bool` | `false` | no |
| <a name="input_container_app_ingress_ip_security_restrictions"></a> [container\_app\_ingress\_ip\_security\_restrictions](#input\_container\_app\_ingress\_ip\_security\_restrictions) | (Optional) List of IP security restrictions for the ingress. Each restriction can apply to multiple IP addresses or ranges. The action types in an all ip\_security\_restriction blocks must be the same for the ingress, mixing Allow and Deny rules is not currently supported by the service. | <pre>list(object({<br>    action           = string<br>    ip_address_range = list(string)<br>    name             = string<br>    description      = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_container_app_ingress_target_port"></a> [container\_app\_ingress\_target\_port](#input\_container\_app\_ingress\_target\_port) | The target port on the container for the Ingress traffic. All Ingress setting can be enabled when this is specified | `number` | `null` | no |
| <a name="input_container_app_ingress_traffic_weight_label"></a> [container\_app\_ingress\_traffic\_weight\_label](#input\_container\_app\_ingress\_traffic\_weight\_label) | (Optional) The label to apply to the revision as a name prefix for routing traffic. | `string` | `null` | no |
| <a name="input_container_app_ingress_traffic_weight_latest_revision"></a> [container\_app\_ingress\_traffic\_weight\_latest\_revision](#input\_container\_app\_ingress\_traffic\_weight\_latest\_revision) | (Optional) Use the latest revision for traffic weight. Defaults to true. | `bool` | `true` | no |
| <a name="input_container_app_ingress_traffic_weight_percentage"></a> [container\_app\_ingress\_traffic\_weight\_percentage](#input\_container\_app\_ingress\_traffic\_weight\_percentage) | The percentage of traffic weight for the ingress. Defaults to 100. The percentage of traffic which should be sent this revision | `number` | `100` | no |
| <a name="input_container_app_ingress_traffic_weight_revision_suffix"></a> [container\_app\_ingress\_traffic\_weight\_revision\_suffix](#input\_container\_app\_ingress\_traffic\_weight\_revision\_suffix) | (Optional) The suffix string to which this traffic\_weight applies. | `string` | `null` | no |
| <a name="input_container_app_ingress_transport"></a> [container\_app\_ingress\_transport](#input\_container\_app\_ingress\_transport) | (Optional) The transport method for the Ingress. Possible values are auto, http, http2 and tcp. Defaults to auto. | `string` | `null` | no |
| <a name="input_container_app_init_containers"></a> [container\_app\_init\_containers](#input\_container\_app\_init\_containers) | Set of init containers for the Container App | <pre>set(object({<br>    args    = optional(list(string))<br>    command = optional(list(string))<br>    cpu     = number<br>    image   = string<br>    name    = string<br>    memory  = string<br>    env = optional(list(object({<br>      name        = string<br>      secret_name = optional(string)<br>      value       = optional(string)<br>    })))<br>    volume_mounts = optional(list(object({<br>      name = string<br>      path = string<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_container_app_name"></a> [container\_app\_name](#input\_container\_app\_name) | The name of the Container App | `string` | `null` | no |
| <a name="input_container_app_registry"></a> [container\_app\_registry](#input\_container\_app\_registry) | The registry configuration for the Container App | <pre>object({<br>    server               = string<br>    username             = optional(string)<br>    password_secret_name = optional(string)<br>    identity             = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_container_app_revision_mode"></a> [container\_app\_revision\_mode](#input\_container\_app\_revision\_mode) | The revision mode of the Container App. Possible values include `Single` and `Multiple` | `string` | `"Single"` | no |
| <a name="input_container_app_secrets"></a> [container\_app\_secrets](#input\_container\_app\_secrets) | The secrets configuration for the Container App | <pre>list(object({<br>    name                = string<br>    identity            = optional(string)<br>    key_vault_secret_id = optional(string)<br>    value               = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_container_app_workload_profile_name"></a> [container\_app\_workload\_profile\_name](#input\_container\_app\_workload\_profile\_name) | (Optional) The name of the Workload Profile in the Container App Environment to place this Container App | `string` | `null` | no |
| <a name="input_create_container_app"></a> [create\_container\_app](#input\_create\_container\_app) | Set value whether to create Container Apps or not. | `bool` | `false` | no |
| <a name="input_create_container_app_environment"></a> [create\_container\_app\_environment](#input\_create\_container\_app\_environment) | Set value whether to create a Container App Environment or not. | `bool` | `false` | no |
| <a name="input_create_rg"></a> [create\_rg](#input\_create\_rg) | Set value whether to create a Resource group or not. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of the resource group | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) The ID for the Log Analytics Workspace to link this Container Apps Managed Environment to. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Map of tags to be applied to all resources created as part of this module | `map(string)` | `{}` | no |
| <a name="input_workload_profiles"></a> [workload\_profiles](#input\_workload\_profiles) | List of workload profiles to be created in the Container App Environment. Workload profile type for the workloads to run on. Possible values include `Consumption`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16` and `E32`. | <pre>list(object({<br>    name                  = string<br>    workload_profile_type = string<br>    maximum_count         = number<br>    minimum_count         = number<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | The ID of the created Container Apps Environment |
| <a name="output_container_app_environment_name"></a> [container\_app\_environment\_name](#output\_container\_app\_environment\_name) | The name of the created Container Apps Environment |
| <a name="output_container_app_fqdn"></a> [container\_app\_fqdn](#output\_container\_app\_fqdn) | The FQDN of the created Container App |
| <a name="output_container_app_id"></a> [container\_app\_id](#output\_container\_app\_id) | The ID of the created Container App |
| <a name="output_container_app_name"></a> [container\_app\_name](#output\_container\_app\_name) | The name of the created Container App |
| <a name="output_container_rg_name"></a> [container\_rg\_name](#output\_container\_rg\_name) | The name of the created RG |
<!-- END_TF_DOCS -->
