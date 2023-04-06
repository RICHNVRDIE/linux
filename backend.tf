terraform {
  backend "azurerm" {
    resource_group_name  = "rg2"
    storage_account_name = "winstrom"
    container_name       = "container"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
    subscription_id      = "b5f306d2-971d-4c83-83c2-2c7b69f22671"
    tenant_id            = "9fead588-3912-437d-9b8d-03b1e59028d3"
    client_id            = "debcdec1-a295-4545-8615-4bf16756cd80"
    client_secret 	 = "obv8Q~3rXng3zM2PqhrMlWt3N7TLz4NsOtxPIbdC"
  }
}
