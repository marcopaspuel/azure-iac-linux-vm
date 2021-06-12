provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "azure-iac-linux-vm-rg"
    storage_account_name = "tstate6257"
    container_name       = "tstate"
    key                  = "terraform.tfstate"
  }
}

module "resource_group" {
  source               = "../../modules/resource_group"
  resource_group       = var.resource_group
  location             = var.location
  project              = var.project
}
module "network" {
  source                = "../../modules/network"
  address_space         = var.address_space
  location              = var.location
  virtual_network_name  = var.virtual_network_name
  vm_name               = var.vm_name
  resource_type         = "NET"
  resource_group        = module.resource_group.resource_group_name
  address_prefixes      = var.address_prefixes
  project               = var.project
}

module "nsg-test" {
  source                = "../../modules/networksecuritygroup"
  location              = var.location
  vm_name               = var.vm_name
  resource_type         = "NSG"
  resource_group        = module.resource_group.resource_group_name
  subnet_id             = module.network.subnet_id_test
  address_prefixes      = var.address_prefixes
  project               = var.project
}

module "publicip" {
  source           = "../../modules/publicip"
  location         = var.location
  vm_name          = var.vm_name
  resource_type    = "publicip"
  resource_group   = module.resource_group.resource_group_name
  project          = var.project
}

module "vm" {
  source               = "../../modules/vm"
  location             = var.location
  resource_group       = module.resource_group.resource_group_name
  vm_name              = var.vm_name
  vm_size              = var.vm_size
  resource_type        = "vm"
  subnet_id            = module.network.subnet_id_test
  public_ip_address_id = module.publicip.public_ip_address_id
  vm_admin_username    = var.vm_admin_username
  vm_public_key        = var.vm_public_key
  storage_account_type = var.storage_account_type
  disk_size_gb         = var.disk_size_gb
  project              = var.project
}
