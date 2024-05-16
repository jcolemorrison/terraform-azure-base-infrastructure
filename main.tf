terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.103.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# Variables
variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure resources."
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group in which to create the Azure resources."
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "myVNet"
}

variable "vnet_address_space" {
  description = "The address space of the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_name" {
  description = "The name of the public subnet."
  type        = string
  default     = "publicSubnet"
}

variable "public_subnet_address" {
  description = "The address of the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_name" {
  description = "The name of the private subnet."
  type        = string
  default     = "privateSubnet"
}

variable "private_subnet_address" {
  description = "The address of the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_ip_name" {
  description = "The name of the public IP."
  type        = string
  default     = "myPublicIP"
}

variable "nat_gateway_name" {
  description = "The name of the NAT gateway."
  type        = string
  default     = "myNATGateway"
}

variable "bastion_name" {
  description = "The name of the Azure Bastion Host."
  type        = string
  default     = "myBastionHost"
}

variable "bastion_address_prefix" {
  description = "The address prefix of the Azure Bastion Host."
  type        = string
  default     = "10.0.3.0/27"
}

# Resources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_address]
}

resource "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_address]
}

resource "azurerm_public_ip" "nat" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                  = var.nat_gateway_name
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  sku_name              = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id     = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "public" {
  subnet_id      = azurerm_subnet.public.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.bastion_address_prefix]
}

resource "azurerm_public_ip" "bastion" {
  name                = "myBastionPublicIP"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = var.bastion_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# Outputs
output "virtual_network_id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet."
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet."
  value       = azurerm_subnet.private.id
}