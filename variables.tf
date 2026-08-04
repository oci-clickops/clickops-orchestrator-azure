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
  description = "Oracle ADB-S instances using handed-off Azure foundation IDs."
  type = map(object({
    name                     = string
    display_name             = optional(string)
    location                 = string
    resource_group_name      = string
    subnet_id                = string
    virtual_network_id       = string
    admin_password           = string
    db_workload              = optional(string, "OLTP")
    compute_model            = optional(string, "ECPU")
    compute_count            = optional(number, 2)
    data_storage_size_in_tbs = optional(number, 1)
    db_version               = optional(string, "19c")
    license_model            = optional(string, "BringYourOwnLicense")
  }))
  default = {}
}
