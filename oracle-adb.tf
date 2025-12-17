# Oracle Autonomous Database Serverless (ADB-S) at Azure
# Uses azurerm_oracle_autonomous_database resource from AzureRM provider

locals {
  # Enrich ADB configs with resolved resource IDs
  oracle_autonomous_databases = {
    for key, adb in var.oracle_autonomous_databases : key => merge(adb, {
      resource_group_name = local.resource_ids.resource_groups[adb.resource_group_key].name
      location            = local.resource_ids.resource_groups[adb.resource_group_key].location
      subnet_id           = local.resource_ids.subnets[adb.network_key][adb.subnet_key]
      virtual_network_id  = local.resource_ids.networks[adb.network_key]
      display_name        = coalesce(adb.display_name, adb.name)
    })
  }
}

resource "azurerm_oracle_autonomous_database" "this" {
  for_each = local.oracle_autonomous_databases

  name                = each.value.name
  display_name        = each.value.display_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  # Network configuration (required for private endpoint)
  subnet_id          = each.value.subnet_id
  virtual_network_id = each.value.virtual_network_id

  # Compute configuration
  compute_model = each.value.compute_model
  compute_count = each.value.compute_count

  # Storage configuration
  data_storage_size_in_tbs         = each.value.data_storage_size_in_tbs
  auto_scaling_for_storage_enabled = each.value.auto_scaling_for_storage_enabled

  # Database configuration
  db_workload            = each.value.db_workload
  db_version             = each.value.db_version
  admin_password         = each.value.admin_password
  character_set          = each.value.character_set
  national_character_set = each.value.national_character_set

  # Licensing and compliance
  license_model                   = each.value.license_model
  auto_scaling_enabled            = each.value.auto_scaling_enabled
  mtls_connection_required        = each.value.mtls_connection_required
  backup_retention_period_in_days = each.value.backup_retention_period_in_days

  # Ignore password changes after creation
  lifecycle {
    ignore_changes = [admin_password]
  }

  depends_on = [module.resource_group, module.vnet]
}

