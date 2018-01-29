resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "East US"

    tags {
        environment = "Terraform Demo"
    }
}