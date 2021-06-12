resource "azurerm_network_interface" "test" {
  name                = "${var.vm_name}-${var.resource_type}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_address_id
  }

  tags = {
    Project = var.project
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = "${var.vm_name}-${var.resource_type}"
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [azurerm_network_interface.test.id]
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.vm_public_key)
  }
  os_disk {
    name                 = "OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Project = var.project
  }
}
