# Cloud Architecture and Policy RAG POC

A synthetic-data learning project for Azure AI Foundry, hybrid retrieval, managed identity, and model tool calling. No real enterprise documents should be used.

## Current POC slice

- Five synthetic policy documents in `docs/`.
- A 15-question retrieval benchmark in `evaluation/golden_questions.jsonl`.
- App-driven Blob-to-Search ingestion. Markdown is chunked locally, embedded through an Azure OpenAI-compatible model deployment, and pushed into the Free Search index using Entra ID.
- A FastAPI `/ask` endpoint that retrieves with keyword plus vector search, answers with citations, and exposes a deterministic monthly-cost estimator as a model function tool.
- Azure credentials use `DefaultAzureCredential`: Azure CLI locally, managed identity when hosted.

## Model prerequisite

Terraform provisions `GlobalStandard` pay-per-token deployments for `gpt-5-mini` and `text-embedding-3-small`, a Foundry Project named `ragagent-poc`, and a keyless Azure AI Search project connection. The application-managed chat model endpoint is `terraform output -raw foundry_openai_endpoint`; the agent runner uses `terraform output -raw foundry_project_endpoint`. These deployments are token-billed, not fixed provisioned-throughput capacity. Global Standard can process inference in any Azure region, so use synthetic data unless that processing boundary is acceptable.

## Run locally

From the repository root, using PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-app.txt
Copy-Item .env.example .env
az login
$env:PYTHONPATH = "src"
```

Edit `.env` with the deployed model endpoint and names; the app loads it automatically. `AZURE_CLIENT_ID` selects the Terraform-created user-assigned managed identity in Azure. Locally, `DefaultAzureCredential` falls back to the signed-in Azure CLI user; that user needs `Storage Blob Data Contributor` on the storage account, `Search Index Data Contributor` on the Search service, and `Cognitive Services OpenAI User` on the Foundry account. The app identity has Blob read and Search index write permissions plus model inference access.

```powershell
python -m rag_agent.ingest --docs docs
python -m uvicorn rag_agent.app:app --app-dir src --reload
```

Open `http://127.0.0.1:8000/docs` to exercise `/ask`. Retrieval evaluation makes embedding and Search calls for each question:

```powershell
python evaluation\evaluate_retrieval.py
```

## Run the Foundry-managed agent

After applying Terraform and allowing role assignments to propagate, run from the repository root:

```powershell
$env:PYTHONPATH = "src"
python -m rag_agent.foundry_agent "Which Search tier is the default for a small RAG proof of concept?"
```

The runner creates a new version of `cloud-architecture-policy-agent`, invokes it through the Foundry Project endpoint, and leaves the version in the Foundry project so you can inspect it in the portal. The agent requests policy retrieval through a custom function; the local runner executes the existing Entra-authenticated hybrid Search path and returns short, source-labeled excerpts for citations. Cost-related prompts can call the deterministic local cost function. Each invocation creates a version and makes model calls; clean up unused agent versions in Foundry when finished.

## Agent Service next step

The FastAPI endpoint remains as a local baseline, while `rag_agent.foundry_agent` uses the Foundry-managed prompt-agent runtime. Both paths use the same synthetic corpus, Search index, and deterministic cost estimator.

The evaluation reports Recall@5, MRR@5, and expected-term coverage for expected source documents. It is a retrieval check, not a Foundry groundedness score. The cost tool uses illustrative Central US retail rates; it is not a quote and excludes model tokens, network traffic, and taxes.

## Content Safety guardrails

The RAG application and Foundry runner scan text at input and output boundaries and scan retrieved Search excerpts before model use. Unsafe or unavailable Safety analysis fails closed. Retrieved text is wrapped and marked as untrusted data, and policy responses are checked to ensure citations refer to chunks returned by Search.

Set `AZURE_CONTENT_SAFETY_ENDPOINT` and optionally `AZURE_CONTENT_SAFETY_THRESHOLD` (default `2`) in `.env`. The account is defined by Terraform, and the app identity plus the Terraform executor receive `Cognitive Services User` on the standalone Safety account. Document ingestion also rejects a chunk if Safety returns a severity at or above the threshold.

The Safety check is currently not a Foundry model deployment filter. It is explicit application/tool-path enforcement, so it must be called at every ingestion and response boundary.

## Cost and security notes

Free Search is shared and limited; it may be unsuitable for production or high availability. This project intentionally uses client-driven indexing because the Free tier doesn't support Search-managed outbound identity for Blob indexers. The sample app currently does not call Content Safety or Foundry Evaluations; those are the next learning slices after basic retrieval works. Keep local `.env` out of Git and never put keys in it. The model endpoint is configured for Entra token authentication.