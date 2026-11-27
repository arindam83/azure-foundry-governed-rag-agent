# Tagging and cost policy

## Required resource tags

- `project`: short project identifier.
- `environment`: `dev`, `test`, or `prod`.
- `owner`: team alias responsible for the workload.
- `expiresOn`: ISO date when temporary POC resources should be reviewed or removed.

## Cost controls

- Prefer consumption-based model inference and the smallest Search tier that can support the experiment.
- Set explicit input/output token limits in the application and avoid sending the entire source corpus to a model.
- Sample telemetry and exclude payload contents unless a specific debugging task requires them.
- Review cost by resource group weekly during the POC.
- Delete dedicated, always-on services when the experiment is inactive; preserve source documents separately if they are needed to rebuild indexes.
- Treat daily ingestion caps as an emergency guardrail, not a substitute for filtering telemetry at source.