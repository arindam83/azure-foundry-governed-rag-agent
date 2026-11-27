resource "azurerm_cognitive_account" "foundry" {
  name                          = "${local.unique_name}-foundry"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  kind                          = "AIServices"
  sku_name                      = "S0"
  custom_subdomain_name         = "${local.unique_name}-foundry"
  local_auth_enabled            = false
  project_management_enabled    = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_cognitive_deployment" "chat" {
  name                 = "gpt-5-mini"
  cognitive_account_id = azurerm_cognitive_account.foundry.id

  model {
    format  = "OpenAI"
    name    = "gpt-5-mini"
    version = "2025-08-07"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 1
  }
}

resource "azurerm_cognitive_deployment" "embeddings" {
  name                 = "text-embedding-3-small"
  cognitive_account_id = azurerm_cognitive_account.foundry.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-small"
    version = "1"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 1
  }
}

resource "azapi_resource" "foundry_project" {
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = "ragagent-poc"
  parent_id = azurerm_cognitive_account.foundry.id
  location  = azurerm_resource_group.main.location

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      displayName = "Cloud Architecture Policy Agent"
      description = "Foundry prompt agent project for the synthetic architecture and governance RAG POC."
    }
  }

  response_export_values = ["identity.principalId", "properties.endpoints"]
}

resource "azurerm_cognitive_account" "content_safety" {
  name                          = "${local.unique_name}-safety"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  kind                          = "ContentSafety"
  sku_name                      = "S0"
  custom_subdomain_name         = "${local.unique_name}-safety"
  local_auth_enabled            = false
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}
