resource "azurerm_network_interface" "myterraformnic" {
    name                = "myNIC"
    location            = "East US"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }

    byte_length = 8
}


resource "azurerm_storage_account" "mystorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    location            = "East US"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}


resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "East US"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "juda"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/juda/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOH1O1am27FlE7HE4MsBJygG01yM3H8ecNWYQXrEMVqyQ7dWzEtBuhCdDyPR437Cd0SAxzw96bUglCyqB6HrcSr2iwwI8u/kkW0Ulxxa2SZKvf4fe3ZMDCYmecz/3q8nrcARNVhg/epQGP2HTvZU1EgJvLU1u8fWWBy+ZCrrXu4hb/4R5fL/G0RQn3midHEP6ll2FCyY1SDLwG8pwfluSZ4OpmT7CmvL7K4y+Po9V4eEqbG4RQM4bzldGto1dDur49NYyWtycdFwi9pUNPR8oZYNhw4GcP8jM0opno0jl8tN0GxLG3jv5Y7XmJExdXDMT9a3VDjko4ena0dNBWyggn juda@msft"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}