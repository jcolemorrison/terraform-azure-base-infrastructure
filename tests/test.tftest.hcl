run "resource_group_validation" {
  assert {
    condition     = azurerm_resource_group.main.name == "testResourceGroup"
    error_message = "incorrect resource group name"
  }

  assert {
    condition     = azurerm_resource_group.main.location == "eastus"
    error_message = "incorrect resource group location"
  }
}

run "virtual_network_validation" {
  assert {
    condition     = azurerm_virtual_network.main.name == "testVNet"
    error_message = "incorrect virtual network name"
  }

  assert {
    condition     = azurerm_virtual_network.main.address_space.0 == "10.255.0.0/16"
    error_message = "incorrect virtual network address space"
  }
}

run "public_subnet_validation" {
  assert {
    condition     = azurerm_subnet.public.name == "testPublicSubnet"
    error_message = "incorrect public subnet name"
  }

  assert {
    condition     = azurerm_subnet.public.address_prefixes.0 == "10.255.1.0/24"
    error_message = "incorrect public subnet address"
  }
}

run "private_subnet_validation" {
  assert {
    condition     = azurerm_subnet.private.name == "testPrivateSubnet"
    error_message = "incorrect private subnet name"
  }

  assert {
    condition     = azurerm_subnet.private.address_prefixes.0 == "10.255.2.0/24"
    error_message = "incorrect private subnet address"
  }
}

run "public_ip_validation" {
  assert {
    condition     = azurerm_public_ip.nat.name == "testPublicIP"
    error_message = "incorrect public IP name"
  }
}

run "nat_gateway_validation" {
  assert {
    condition     = azurerm_nat_gateway.main.name == "testNATGateway"
    error_message = "incorrect NAT gateway name"
  }
}

run "bastion_host_validation" {
  assert {
    condition     = azurerm_bastion_host.main.name == "testBastionHost"
    error_message = "incorrect bastion host name"
  }
}

run "output_validation" {
  assert {
    condition     = output.virtual_network_id == azurerm_virtual_network.main.id
    error_message = "incorrect output for virtual network ID, should match resource ID"
  }

  assert {
    condition     = output.public_subnet_id == azurerm_subnet.public.id
    error_message = "incorrect output for public subnet ID, should match resource ID"
  }

  assert {
    condition     = output.private_subnet_id == azurerm_subnet.private.id
    error_message = "incorrect output for private subnet ID, should match resource ID"
  }
}