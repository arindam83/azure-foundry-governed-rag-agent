resource "azurerm_search_service" "main" {
  name                         = "${local.unique_name}-search"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  sku                          = "free"
  local_authentication_enabled = false

  tags = local.common_tags
}

resource "azurerm_storage_account" "docs" {
  name                            = substr(replace("${local.name_prefix}${random_string.suffix.result}docs", "-", ""), 0, 24)
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  public_network_access_enabled   = true

  blob_properties {
    versioning_enabled = true
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "sources" {
  name                  = "source-documents"
  storage_account_id    = azurerm_storage_account.docs.id
  container_access_type = "private"

  depends_on = [azurerm_role_assignment.terraform_blob_contributor]
}

resource "azapi_resource" "foundry_search_connection" {
  type      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name      = "architecture-search"
  parent_id = azapi_resource.foundry_project.id

  body = {
    properties = {
      category = "CognitiveSearch"
      target   = "https://${azurerm_search_service.main.name}.search.windows.net/"
      authType = "AAD"
    }
  }
}
