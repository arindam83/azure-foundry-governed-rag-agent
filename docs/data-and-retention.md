# Data handling and retention

All material in this repository is synthetic. Do not upload real customer, employee, or confidential architecture documents to this learning environment.

## Classification

- Public: approved for unrestricted release.
- Internal: routine internal engineering guidance; keep access limited to the organization.
- Confidential: sensitive business or security details; do not use in this POC.

## POC handling rules

- Use only synthetic or explicitly approved public source documents.
- Keep source blobs private and grant access through Entra ID.
- Store only the text and metadata needed for retrieval. Avoid indexing secrets and personal information.
- Use a short retention period for logs and delete uploaded test data when the exercise ends.
- Do not log full prompts, retrieved passages, or model responses by default. Record request IDs, latency, token counts, retrieval document IDs, and errors instead.