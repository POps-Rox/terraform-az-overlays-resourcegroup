locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)
  anoa_slug   = "rg"
  rg_name     = coalesce(var.custom_rg_name, data.popsrox_resource_name.rg.result)
}