output "virtual_machines" {
  value = { for key, vm in module.vm : key => { id = vm.resource_id, name = vm.name } }
}

output "oracle_autonomous_databases" {
  value = {
    for key, adb in module.oracle_autonomous_database : key => {
      id            = adb.resource_id
      oci_adbs_ocid = adb.oci_adbs_ocid
      oci_region    = adb.oci_region
    }
  }
}
