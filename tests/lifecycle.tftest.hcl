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
