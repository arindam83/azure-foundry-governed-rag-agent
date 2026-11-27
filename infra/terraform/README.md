# RAG infrastructure

This Terraform root provisions an Azure AI Services account for Azure AI Foundry with `GlobalStandard` pay-per-token deployments for `gpt-5-mini` and `text-embedding-3-small`, a separate Azure AI Content Safety account, Free-tier Azure AI Search, private Blob Storage, and workspace-based Application Insights/Log Analytics. Global Standard inference can be processed in any Azure region; use synthetic data for this POC unless that processing boundary is acceptable. The app-facing user-assigned managed identity reads source blobs, writes and queries Search index data, calls the AI endpoints, and publishes telemetry. The app performs ingestion and pushes embedded documents to Search because the Free tier doesn't support Search-managed identity for outbound indexer access.

Foundry project management is enabled on the account so it can host Foundry Projects and Agent Service prompt agents. Azure doesn't allow enabling this flag after account creation, so Terraform will replace the Foundry account and its two model deployments. Other resources in the resource group, including Search, Storage, Content Safety, and telemetry, are not intended to be replaced. Review `terraform plan` and confirm this exact scope before applying; recreate the project and agent after the account replacement.

Terraform uses Entra ID for Storage data-plane operations and assigns the identity running Terraform `Storage Blob Data Contributor` on this storage account so it can manage the private container without account keys.
All resources are configured for the same region through `location`.

Local/key authentication is disabled for the AI accounts, Search, Storage, Log Analytics, and Application Insights. No access keys or connection strings are exported. The application should use its assigned managed identity and Azure SDK `DefaultAzureCredential`/managed identity authentication. For Application Insights SDKs, configure Entra authentication (`Authorization=AAD`) with the non-secret connection string from the deployed App Insights resource and the assigned `Monitoring Metrics Publisher` role.

## Deploy

Prerequisites: Terraform 1.5+, Azure CLI logged into the target tenant/subscription, and permission to create the resources and assign Azure RBAC roles. Set `ARM_SUBSCRIPTION_ID` or configure the AzureRM provider's subscription selection through the environment.

```powershell
az login
$env:ARM_SUBSCRIPTION_ID = "<subscription-id>"
terraform init
terraform plan -out main.tfplan
terraform apply main.tfplan
```

Use `terraform output` to retrieve endpoints and the app identity client ID. Assign that user-assigned identity to the application runtime. Resource names use a generated suffix; retain the Terraform state to keep the deployed names stable.

This starter allows public network access to the services while requiring Entra ID authentication. Restrict network access or add private endpoints/VNet integration to meet the deployment's network boundary requirements. Service availability and pricing vary by Azure region; confirm that the selected region supports Azure AI Foundry and Content Safety before deployment.