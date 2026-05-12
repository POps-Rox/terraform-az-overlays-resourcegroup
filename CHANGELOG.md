# Changelog

All notable changes to this project are documented here. Format based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-05-11

### Changed (BREAKING)

- Upgraded `hashicorp/azurerm` provider constraint from `~> 3.116` to `~> 4.20`.
- Raised minimum Terraform CLI version from `>= 1.9` to `>= 1.10`.

### Added

- New `azure/azapi ~> 2.0` provider declaration in `versions.tf` (root, example,
  and test) for fleet alignment.
- `versions.tf` files added to `examples/main/` and `tests/main/` so the example
  and test stacks declare their own provider versions explicitly.
- Comment in the example/test `provider "azurerm"` blocks noting that
  `subscription_id` is provided by the consumer via the `ARM_SUBSCRIPTION_ID`
  environment variable (required by azurerm 4.x).

### Notes

- No mechanical attribute renames were required — module only manages
  `azurerm_resource_group` and `azurerm_management_lock`, both of which retain
  their 3.x attribute shapes in 4.x.
- No `retention_policy`, `private_endpoint_network_policies_enabled`, or
  role-assignment changes were needed.
- CI may show transitive provider-constraint failures on example/test stacks
  until the upstream `terraform-az-overlays-azregionslookup` module is also
  bumped to `~> 4.20`. Failures resolve as Phase 1 PRs land.

[2.0.0]: https://github.com/POps-Rox/terraform-az-overlays-resourcegroup/releases/tag/v2.0.0
