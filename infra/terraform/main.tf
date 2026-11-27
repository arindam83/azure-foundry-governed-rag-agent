resource "random_string" "suffix" {
  length  = 5
  lower   = true
  numeric = true
  upper   = false
  special = false
}

locals {
  name_prefix = substr(lower(replace("${var.project_name}${var.environment}", "/[^a-z0-9]/", "")), 0, 12)
  unique_name = "${local.name_prefix}-${random_string.suffix.result}"
  common_tags = merge(var.tags, {
    project     = var.project_name
    environment = var.environment
  })
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = coalesce(var.resource_group_name, "rg-${local.unique_name}")
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${local.unique_name}-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}