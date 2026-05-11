# --------------------------
# CONFIGURE OUR AZURE PROVIDER
# --------------------------

provider "azurerm" {
  features {}
  # subscription_id is provided by the consumer via ARM_SUBSCRIPTION_ID env var
}

# ---------
# VARIABLES
# ---------
variable "location" {
  description = "Azure region in which instance will be hosted"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Name of the workload's environnement"
  type        = string
  default     = "dev"
}

variable "workload_name" {
  description = "Name of the workload_name"
  type        = string
  default     = "workload"
}

variable "org_name" {
  description = "Name of the organization"
  type        = string
  default     = "anoa"
}

variable "add_tags" {
  description = "Map of custom tags."
  type        = map(string)
  default     = {}
}

variable "enable_resource_locks" {
  description = "(Optional) Enable resource locks, default is false. If true, resource locks will be created for the resource group and the storage account."
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}

variable "custom_resource_group_name" {
  description = "(Optional) Custom name for the resource group. If not set, the module will generate a name based on the workload_name, environment and org_name."
  type        = string
  default     = null
}

variable "use_location_short_name" {
  description = "Use Short Location Name in the naming provider to generate default resource name."
  type        = bool
  default     = false
}

# ---------------
# CREATE THE RG
# ---------------
module "rg" {
  source = "../../"

  // Resource group name and location
  location                = var.location # This is the short location name (e.g. "eus")
  org_name                = var.org_name
  environment             = var.environment
  workload_name           = var.workload_name
  use_location_short_name = var.use_location_short_name # This is to enable short location name (e.g. "eus") as part of the resource group name
  custom_rg_name          = var.custom_resource_group_name != null ? var.custom_resource_group_name : null

  // Enable resource locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Add tags
  add_tags = var.add_tags
}

# -------
# OUTPUTS
# -------
output "resource_group_name" {
  value       = module.rg.resource_group_name
  description = "Resource group name"
}

output "resource_group_id" {
  value       = module.rg.resource_group_id
  description = "Resource group generated id"
}

output "resource_group_location" {
  value       = module.rg.resource_group_location
  description = "Resource group location (region)"
}
