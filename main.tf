resource "azurerm_resource_group" "myrg" {
  name     = "project2"
  location = "West Europe"
}

resource "azurerm_network_security_group" "my-nsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  security_rule {
    name                       = "ssh"
    priority                   = 1101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "8080"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "myip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "my-subnet" 
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "mynic" {
  name                = "my-nic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myip.id
    
  }
}

resource "azurerm_network_interface_security_group_association" "my-nsg" {
  network_interface_id      = azurerm_network_interface.mynic.id
  network_security_group_id = azurerm_network_security_group.my-nsg.id
}

resource "azurerm_linux_virtual_machine" "linux" {
  name                = "linux"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Password@123"
  disable_password_authentication = "false"
  network_interface_ids = [azurerm_network_interface.mynic.id]


  os_disk {
    name                 = "my-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine_extension" "extension" {
  name                 = "myvm-extension"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${filebase64("script.sh")}"
    }
SETTINGS
}