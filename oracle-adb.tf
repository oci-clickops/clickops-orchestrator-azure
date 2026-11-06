module "oracle_autonomous_database" {
  for_each = var.oracle_autonomous_databases
  source   = "git::https://github.com/oci-landing-zones/terraform-oci-multicloud-azure.git//modules/azurerm-ora-adbs?ref=v0.1.2"

  name                     = each.value.name
  display_name             = coalesce(each.value.display_name, each.value.name)
  location                 = each.value.location
  resource_group_name      = each.value.resource_group_name
  subnet_id                = each.value.subnet_id
  virtual_network_id       = each.value.virtual_network_id
  mtls_connection_required = each.value.mtls_connection_required
  admin_password           = each.value.admin_password
  db_workload              = each.value.db_workload
  compute_model            = each.value.compute_model
  compute_count            = each.value.compute_count
  data_storage_size_in_tbs = each.value.data_storage_size_in_tbs
  db_version               = each.value.db_version
  license_model            = each.value.license_model
}
