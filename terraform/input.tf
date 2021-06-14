# Azure GUIDS
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Resource Group/Location
variable "location" {}
variable "resource_group" {}

# Network
variable virtual_network_name {}
variable address_space {}
variable "address_prefixes" {}

# Virtual Machine
variable "vm_name" {}
variable "vm_size" {}
variable vm_admin_username {}
variable vm_public_key {}

# Virtual Machine Disk
variable "storage_account_type" {}
variable "disk_size_gb" {}

# Public IP
variable "public_ip_sku" {}

# Tags
variable "project" {}
