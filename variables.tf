variable "virtual_machines" {
  description = "Private Linux VMs using handed-off Azure foundation IDs."
  type = map(object({
    name                      = string
    location                  = string
    resource_group_name       = string
    subnet_id                 = string
    network_security_group_id = string
    size                      = string
    admin_username            = string
    ssh_public_key            = string
  }))
  default = {}
}

variable "oracle_autonomous_databases" {
  description = "Oracle ADB-S instances with private connectivity or a public endpoint requiring mTLS."
  type = map(object({
    name                     = string
    display_name             = optional(string)
    location                 = string
    resource_group_name      = string
    network_access           = optional(string, "private")
    subnet_id                = optional(string)
    virtual_network_id       = optional(string)
    mtls_connection_required = optional(bool, false)
    admin_password           = string
    db_workload              = optional(string, "OLTP")
    compute_model            = optional(string, "ECPU")
    compute_count            = optional(number, 2)
    data_storage_size_in_tbs = optional(number, 1)
    db_version               = optional(string, "19c")
    license_model            = optional(string, "BringYourOwnLicense")
  }))
  default = {}

  validation {
    condition = alltrue([
      for adb in values(var.oracle_autonomous_databases) :
      adb.network_access == "private" ? (
        try(length(trimspace(adb.subnet_id)) > 0, false) &&
        try(length(trimspace(adb.virtual_network_id)) > 0, false)
        ) : (
        adb.network_access == "public" &&
        adb.subnet_id == null &&
        adb.virtual_network_id == null &&
        adb.mtls_connection_required
      )
    ])
    error_message = "Each ADB must use network_access private with nonempty subnet_id and virtual_network_id, or public with no network IDs and mtls_connection_required set to true."
  }
}
