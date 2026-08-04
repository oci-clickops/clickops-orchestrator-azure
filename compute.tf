module "vm" {
  for_each = var.virtual_machines
  source   = "Azure/avm-res-compute-virtualmachine/azurerm"
  version  = "0.19.0"

  name                            = each.value.name
  location                        = each.value.location
  resource_group_name             = each.value.resource_group_name
  sku_size                        = each.value.size
  admin_username                  = each.value.admin_username
  os_type                         = "Linux"
  zone                            = null
  disable_password_authentication = true
  admin_ssh_keys                  = [{ username = each.value.admin_username, public_key = each.value.ssh_public_key }]

  network_interfaces = {
    nic = {
      name                    = "${each.value.name}-nic"
      network_security_groups = { nsg = { network_security_group_resource_id = each.value.network_security_group_id } }
      ip_configurations = {
        private = {
          name                          = "private"
          private_ip_subnet_resource_id = each.value.subnet_id
          private_ip_address_allocation = "Dynamic"
        }
      }
    }
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
