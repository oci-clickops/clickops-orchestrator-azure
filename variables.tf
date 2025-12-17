# OCI modular orchestration pattern - consolidated dependency injection
# Allows external modules to override local JSON configurations
# Enables composition: parent modules can inject computed resources as dependencies
variable "module_dependencies" {
  type = object({
    resource_groups = optional(any, null)
    networks        = optional(any, null)
    security_groups = optional(any, null)
  })
  default     = {}
  description = "Optional dependencies from parent modules (overrides JSON configs)"
}

# Resource Configuration Patterns:
# - resource_id: null = create new resource, non-null = use existing resource by ID
# - optional fields with defaults reduce JSON configuration verbosity  
# - *_key fields reference keys from respective resource variables


variable "resource_groups" {
  type = map(object({
    name        = string
    location    = string
    resource_id = optional(string)
  }))
  default = {}
}

variable "networks" {
  type = map(object({
    resource_group_key = optional(string)
    resource_id        = optional(string)
    name               = string
    cidr               = optional(string)
    subnets = map(object({
      name        = string
      cidr        = optional(string)
      resource_id = optional(string)
    }))
  }))
  default = {}
}

variable "security_groups" {
  type = map(object({
    resource_group_key = optional(string)
    resource_id        = optional(string)
    name               = string
    rules = optional(list(object({
      name        = string
      port        = number
      protocol    = optional(string, "Tcp")
      source      = optional(string, "*")
      priority    = number
      description = optional(string, "")
    })), [])
  }))
  default = {}
}

variable "virtual_machines" {
  type = map(object({
    resource_group_key = string
    network_key        = string
    subnet_key         = string
    security_group_key = string
    name               = string
    size               = string
    admin_username     = string
    ssh_key_path       = optional(string, "~/.ssh/azure_vm_key.pub")
    create_public_ip   = optional(bool, true)
    public_ip_sku      = optional(string, "Basic")
  }))
  default = {}

  # Free Tier Compliance: Validation rules reference centralized constants from validations.tf
  # This pattern enables shared validation logic across multiple resource types
  validation {
    condition     = alltrue([for vm in var.virtual_machines : contains(local.validation_config.valid_vm_sizes, vm.size)])
    error_message = local.validation_config.vm_size_error_template
  }

  validation {
    condition     = alltrue([for vm in var.virtual_machines : contains(local.validation_config.valid_public_ip_skus, vm.public_ip_sku)])
    error_message = local.validation_config.public_ip_sku_error_template
  }
}

# Oracle Autonomous Database Serverless (ADB-S) at Azure
# Uses azurerm_oracle_autonomous_database resource
variable "oracle_autonomous_databases" {
  type = map(object({
    resource_group_key                = string
    network_key                       = string
    subnet_key                        = string
    name                              = string
    display_name                      = optional(string)
    location                          = optional(string, "eastus")
    db_workload                       = optional(string, "OLTP")
    compute_model                     = optional(string, "ECPU")
    compute_count                     = optional(number, 2)
    data_storage_size_in_tbs          = optional(number, 1)
    db_version                        = optional(string, "19c")
    license_model                     = optional(string, "BringYourOwnLicense")
    admin_password                    = string
    character_set                     = optional(string, "AL32UTF8")
    national_character_set            = optional(string, "AL16UTF16")
    auto_scaling_enabled              = optional(bool, true)
    auto_scaling_for_storage_enabled  = optional(bool, false)
    mtls_connection_required          = optional(bool, false)
    backup_retention_period_in_days   = optional(number, 60)
    customer_contacts                 = optional(list(string), [])
  }))
  default     = {}
  description = "Oracle Autonomous Database Serverless instances (OracleDB@Azure)"

  validation {
    condition     = alltrue([for adb in var.oracle_autonomous_databases : contains(["OLTP", "DW", "AJD", "APEX"], adb.db_workload)])
    error_message = "db_workload must be one of: OLTP, DW, AJD, APEX"
  }

  validation {
    condition     = alltrue([for adb in var.oracle_autonomous_databases : contains(["ECPU", "OCPU"], adb.compute_model)])
    error_message = "compute_model must be either ECPU or OCPU"
  }

  validation {
    condition     = alltrue([for adb in var.oracle_autonomous_databases : contains(["LicenseIncluded", "BringYourOwnLicense"], adb.license_model)])
    error_message = "license_model must be either LicenseIncluded or BringYourOwnLicense"
  }
}