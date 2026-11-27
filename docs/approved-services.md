# Approved cloud services

## Purpose

This fictional policy defines the default Azure services allowed for internal proof-of-concept workloads. It is not production guidance.

## Approved defaults

- General-purpose object storage: Azure Blob Storage, Standard performance, locally redundant storage (LRS), hot access tier for frequently read source files.
- Small RAG search experiments: Azure AI Search Free when its limits are sufficient. Use Basic only when the workload exceeds Free limits or requires its additional capabilities.
- Application hosting for an intermittently used demo: Azure Container Apps with scale-to-zero enabled and a minimum replica count of zero.
- Telemetry: workspace-based Application Insights connected to a Log Analytics workspace. Avoid verbose request-body logging.

## Exceptions

Use the smallest service tier that meets a documented requirement. Production availability, private networking, data residency, and recovery requirements can require a higher tier. Record the requirement and obtain platform-owner approval before changing a default.