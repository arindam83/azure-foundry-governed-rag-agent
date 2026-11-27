# Identity and secrets

## Requirements

- Prefer a system-assigned or user-assigned managed identity for Azure-hosted workloads.
- Grant only the data-plane roles required by the workload, scoped to the individual resource where practical.
- Do not put account keys, API keys, passwords, or connection strings containing credentials in source code, logs, test data, or Git.
- For local development, use Azure CLI sign-in and `DefaultAzureCredential`; do not commit local credential caches.
- Disable local/key authentication on services when the required Entra data-plane path is available and tested.
- Rotate or remove temporary developer permissions after the POC no longer needs them.

## RAG application role examples

- Search query-only runtime: `Search Index Data Reader`.
- Application-driven indexing runtime: `Search Index Data Contributor`.
- Source documents: `Storage Blob Data Reader`.
- Model inference and Content Safety: the least-privileged supported Cognitive Services data-plane role.

Index creation may require broader Search permissions than query-time access. Prefer a separate deployment identity for index administration rather than granting the runtime identity permanent service-wide administration.