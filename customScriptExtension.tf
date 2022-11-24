resource "random_integer" "suffix" {
  min = 100
  max = 999
}
resource "azurerm_storage_account" "resources" {
  name                     = "vectordemo${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_storage_container" "blob" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.resources.name
  container_access_type = "private"
}
resource "azurerm_storage_blob" "app" {
  name                   = "init.sh"
  storage_account_name   = azurerm_storage_account.resources.name
  storage_container_name = azurerm_storage_container.blob.name
  type                   = "Block"
  source                 = "init.sh"
}
resource "azurerm_virtual_machine_extension" "example" {
  name                 = "app"
  virtual_machine_id   = azurerm_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "fileUris": ["${azurerm_storage_blob.app.url}"],
  "commandToExecute": "./init.sh ${var.apiKey}"
  
 }
SETTINGS
protected_settings = <<PROTECTEDSETTINGS
{
       "storageAccountName": "${azurerm_storage_account.resources.name}",
       "storageAccountKey": "${azurerm_storage_account.resources.primary_access_key}"
}
PROTECTEDSETTINGS
}