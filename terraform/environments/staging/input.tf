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
variable "address_prefix_test" {}
variable address_space {}

# Virtual Machine
variable "vm_name" {}
variable "vm_size" {}
variable vm_admin_username {}
variable vm_public_key {}

# Tags
variable "project" {}
