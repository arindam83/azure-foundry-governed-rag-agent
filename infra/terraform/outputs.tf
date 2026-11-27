output "resource_group_name" {
  description = "Name of the resource group containing the RAG infrastructure."
  value       = azurerm_resource_group.main.name
}

output "foundry_endpoint" {
  description = "Azure AI Foundry/Azure AI Services account endpoint."
  value       = azurerm_cognitive_account.foundry.endpoint
}

output "foundry_project_endpoint" {
  description = "Project endpoint for the Cloud Architecture Policy Foundry agent."
  value       = "https://${azurerm_cognitive_account.foundry.name}.services.ai.azure.com/api/projects/${azapi_resource.foundry_project.name}"
}

output "foundry_openai_endpoint" {
  description = "Azure OpenAI-compatible inference endpoint for deployed Foundry models."
  value       = "https://${azurerm_cognitive_account.foundry.custom_subdomain_name}.openai.azure.com/"
}

output "content_safety_endpoint" {
  description = "Azure AI Content Safety endpoint."
  value       = azurerm_cognitive_account.content_safety.endpoint
}

output "search_endpoint" {
  description = "Azure AI Search endpoint."
  value       = "https://${azurerm_search_service.main.name}.search.windows.net"
}

output "storage_account_name" {
  description = "Storage account containing the private source-documents container."
  value       = azurerm_storage_account.docs.name
}

output "source_container_name" {
  description = "Private Blob container for source architecture documents."
  value       = azurerm_storage_container.sources.name
}

output "app_identity_client_id" {
  description = "Client ID for assigning the user-managed identity to the RAG application."
  value       = azurerm_user_assigned_identity.app.client_id
}

output "app_identity_principal_id" {
  description = "Principal ID of the RAG application's user-managed identity."
  value       = azurerm_user_assigned_identity.app.principal_id
}

output "application_insights_id" {
  description = "Application Insights resource ID; telemetry ingestion uses the app identity and Entra ID."
  value       = azurerm_application_insights.main.id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = azurerm_log_analytics_workspace.main.id
}