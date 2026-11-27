resource "azurerm_log_analytics_workspace" "main" {
  name                         = "log-${local.unique_name}"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  sku                          = "PerGB2018"
  retention_in_days            = 30
  local_authentication_enabled = false
  internet_ingestion_enabled   = true
  internet_query_enabled       = true
  tags                         = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                         = "appi-${local.unique_name}"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  workspace_id                 = azurerm_log_analytics_workspace.main.id
  application_type             = "web"
  local_authentication_enabled = false
  tags                         = local.common_tags
}
