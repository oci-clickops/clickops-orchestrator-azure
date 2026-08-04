output "virtual_machines" {
  value = { for key, vm in module.vm : key => { id = vm.resource_id, name = vm.name } }
}

output "oracle_autonomous_databases" {
  value = { for key, adb in azurerm_oracle_autonomous_database.this : key => { id = adb.id, name = adb.name, display_name = adb.display_name } }
}
