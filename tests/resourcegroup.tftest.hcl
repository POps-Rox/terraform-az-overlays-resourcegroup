# Functional tests for the resource group overlay.
#
# These use mock_provider, so they execute WITHOUT Azure credentials and are
# safe to run on pull requests from forks in a public repository.
#
# Scope note: `terraform validate` proves only that the configuration is
# schema-valid. These tests exercise the module's actual decision logic --
# naming precedence, conditional resources, and tag merging -- which validate
# cannot see. They still do not prove deployability against a real Azure
# subscription; that requires a plan/apply against real state.

mock_provider "azurerm" {}
mock_provider "azapi" {}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "anoa-eus-testworkload-dev-rg"
    }
  }
}

variables {
  location                = "eastus"
  environment             = "dev"
  workload_name           = "testworkload"
  org_name                = "anoa"
  use_location_short_name = true
}

# ---------------------------------------------------------------------------
# Naming precedence
# ---------------------------------------------------------------------------

run "generated_name_is_used_when_no_custom_name_given" {
  command = plan

  assert {
    condition     = azurerm_resource_group.main_rg.name == "anoa-eus-testworkload-dev-rg"
    error_message = "Expected the name from the popsrox_resource_name data source to be used when custom_rg_name is unset, got: ${azurerm_resource_group.main_rg.name}"
  }
}

run "custom_name_overrides_generated_name" {
  command = plan

  variables {
    custom_rg_name = "my-explicit-rg"
  }

  assert {
    condition     = azurerm_resource_group.main_rg.name == "my-explicit-rg"
    error_message = "custom_rg_name must take precedence over the generated name, got: ${azurerm_resource_group.main_rg.name}"
  }
}

run "empty_custom_name_falls_through_to_generated_name" {
  command = plan

  variables {
    custom_rg_name = ""
  }

  # coalesce() skips empty strings; this guards against a regression to a
  # null-only check, which would emit an empty resource group name.
  assert {
    condition     = azurerm_resource_group.main_rg.name == "anoa-eus-testworkload-dev-rg"
    error_message = "An empty custom_rg_name must fall through to the generated name, got: ${azurerm_resource_group.main_rg.name}"
  }
}

# ---------------------------------------------------------------------------
# Conditional resources
# ---------------------------------------------------------------------------

run "locks_are_not_created_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_management_lock.resource_group_level_lock) == 0
    error_message = "enable_resource_locks defaults to false, so no management lock should be planned"
  }
}

run "enabling_locks_creates_exactly_one_lock" {
  command = plan

  variables {
    enable_resource_locks = true
  }

  assert {
    condition     = length(azurerm_management_lock.resource_group_level_lock) == 1
    error_message = "enable_resource_locks = true must create exactly one management lock"
  }

  assert {
    condition     = azurerm_management_lock.resource_group_level_lock[0].lock_level == "CanNotDelete"
    error_message = "lock_level should default to CanNotDelete"
  }

  assert {
    condition     = azurerm_management_lock.resource_group_level_lock[0].name == "anoa-eus-testworkload-dev-rg-CanNotDelete-lock"
    error_message = "Lock name must be derived from the resource group name and lock level, got: ${azurerm_management_lock.resource_group_level_lock[0].name}"
  }
}

run "lock_level_is_configurable" {
  command = plan

  variables {
    enable_resource_locks = true
    lock_level            = "ReadOnly"
  }

  assert {
    condition     = azurerm_management_lock.resource_group_level_lock[0].lock_level == "ReadOnly"
    error_message = "lock_level must be honoured when supplied"
  }
}

# ---------------------------------------------------------------------------
# Tagging
# ---------------------------------------------------------------------------

run "caller_supplied_tags_are_merged_in" {
  command = plan

  variables {
    add_tags = {
      costCenter = "cc-1234"
    }
  }

  assert {
    condition     = azurerm_resource_group.main_rg.tags["costCenter"] == "cc-1234"
    error_message = "Tags passed via add_tags must appear on the resource group"
  }
}

run "location_is_passed_through" {
  command = plan

  assert {
    condition     = azurerm_resource_group.main_rg.location == "eastus"
    error_message = "location input must be applied to the resource group"
  }
}
