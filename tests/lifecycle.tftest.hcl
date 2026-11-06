mock_provider "azurerm" {
  alias = "mock"

  mock_resource "azurerm_network_interface" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-app/providers/Microsoft.Network/networkInterfaces/vmdevapp-nic"
    }
  }

  mock_data "azurerm_oracle_autonomous_database" {
    defaults = {
      oci_url = "https://cloud.oracle.com/db/adbs/ocid1.autonomousdatabase.oc1.example?region=eu-frankfurt-1&compartmentId=ocid1.compartment.oc1.example"
    }
  }
}

mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "tls" {}

run "empty_manifest" {
  command = plan

  providers = {
    azurerm = azurerm.mock
  }
}

run "create_workloads" {
  command = apply

  providers = {
    azurerm = azurerm.mock
  }

  variables {
    virtual_machines = {
      APP = {
        name                      = "vmdevapp"
        location                  = "westeurope"
        resource_group_name       = "rg-dev-app"
        subnet_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/app"
        network_security_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/networkSecurityGroups/app"
        size                      = "Standard_B2s"
        admin_username            = "azureuser"
        ssh_public_key            = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      }
    }
    oracle_autonomous_databases = {
      ADB = {
        name                = "adbdevapp"
        location            = "westeurope"
        resource_group_name = "rg-dev-app"
        subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/adb"
        virtual_network_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet"
        admin_password      = "Synthetic1#Value"
      }
    }
  }
}

run "update_workloads" {
  command = apply

  providers = {
    azurerm = azurerm.mock
  }

  variables {
    virtual_machines = {
      APP = {
        name                      = "vmdevapp"
        location                  = "westeurope"
        resource_group_name       = "rg-dev-app"
        subnet_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/app"
        network_security_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/networkSecurityGroups/app"
        size                      = "Standard_D2s_v5"
        admin_username            = "azureuser"
        ssh_public_key            = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      }
    }
    oracle_autonomous_databases = {
      ADB = {
        name                = "adbdevapp"
        location            = "westeurope"
        resource_group_name = "rg-dev-app"
        subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/adb"
        virtual_network_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet"
        admin_password      = "Synthetic1#Value"
        compute_count       = 4
      }
    }
  }
}

run "delete_workloads" {
  command = apply

  providers = {
    azurerm = azurerm.mock
  }
}

run "public_adb_without_private_network" {
  command   = apply
  providers = { azurerm = azurerm.mock }
  variables {
    oracle_autonomous_databases = {
      PUBLIC = {
        name                     = "adbpublictest"
        location                 = "uksouth"
        resource_group_name      = "rg-test"
        admin_password           = "Synthetic1#Value"
        network_access           = "public"
        mtls_connection_required = true
      }
    }
  }
}

run "reject_public_without_mtls" {
  command   = plan
  providers = { azurerm = azurerm.mock }
  variables {
    oracle_autonomous_databases = {
      PUBLIC = {
        name                = "adbpublictest"
        location            = "uksouth"
        resource_group_name = "rg-test"
        admin_password      = "Synthetic1#Value"
        network_access      = "public"
      }
    }
  }
  expect_failures = [var.oracle_autonomous_databases]
}

run "reject_private_without_network" {
  command   = plan
  providers = { azurerm = azurerm.mock }
  variables {
    oracle_autonomous_databases = {
      PRIVATE = {
        name                = "adbprivatetest"
        location            = "uksouth"
        resource_group_name = "rg-test"
        admin_password      = "Synthetic1#Value"
      }
    }
  }
  expect_failures = [var.oracle_autonomous_databases]
}

run "reject_public_with_private_network" {
  command   = plan
  providers = { azurerm = azurerm.mock }
  variables {
    oracle_autonomous_databases = {
      PUBLIC = {
        name                     = "adbpublictest"
        location                 = "uksouth"
        resource_group_name      = "rg-test"
        admin_password           = "Synthetic1#Value"
        network_access           = "public"
        mtls_connection_required = true
        subnet_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/adb"
        virtual_network_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet"
      }
    }
  }
  expect_failures = [var.oracle_autonomous_databases]
}

run "mixed_private_and_public_adbs" {
  command   = apply
  providers = { azurerm = azurerm.mock }
  variables {
    oracle_autonomous_databases = {
      PRIVATE = {
        name                     = "adbprivatetest"
        location                 = "uksouth"
        resource_group_name      = "rg-test"
        admin_password           = "Synthetic1#Value"
        network_access           = "private"
        mtls_connection_required = true
        subnet_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/adb"
        virtual_network_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet"
      }
      PUBLIC = {
        name                     = "adbpublictest"
        location                 = "uksouth"
        resource_group_name      = "rg-test"
        admin_password           = "Synthetic1#Value"
        network_access           = "public"
        mtls_connection_required = true
        subnet_id                = null
        virtual_network_id       = null
      }
    }
  }
  assert {
    condition     = toset(keys(output.oracle_autonomous_databases)) == toset(["PRIVATE", "PUBLIC"])
    error_message = "Both connectivity modes must be deployed from the same regional map."
  }
}

run "reject_unknown_network_access" {
  command   = plan
  providers = { azurerm = azurerm.mock }
  variables {
    oracle_autonomous_databases = {
      PUBLIC = {
        name                     = "adbpublictest"
        location                 = "uksouth"
        resource_group_name      = "rg-test"
        admin_password           = "Synthetic1#Value"
        network_access           = "internet"
        mtls_connection_required = true
      }
    }
  }
  expect_failures = [var.oracle_autonomous_databases]
}
