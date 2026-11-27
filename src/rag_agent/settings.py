from __future__ import annotations

import os
from dataclasses import dataclass
from urllib.parse import urlparse

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    managed_identity_client_id: str
    foundry_project_endpoint: str
    storage_account_url: str
    source_container: str
    search_endpoint: str
    search_index: str
    model_endpoint: str
    chat_deployment: str
    embedding_deployment: str
    openai_api_version: str
    embedding_dimensions: int
    content_safety_endpoint: str
    content_safety_threshold: int

    @classmethod
    def from_env(cls) -> "Settings":
        required = {
            "AZURE_STORAGE_ACCOUNT_URL": os.getenv("AZURE_STORAGE_ACCOUNT_URL", ""),
            "AZURE_SEARCH_ENDPOINT": os.getenv("AZURE_SEARCH_ENDPOINT", ""),
            "AZURE_MODEL_ENDPOINT": os.getenv("AZURE_MODEL_ENDPOINT", ""),
            "AZURE_CHAT_DEPLOYMENT": os.getenv("AZURE_CHAT_DEPLOYMENT", ""),
            "AZURE_EMBEDDING_DEPLOYMENT": os.getenv("AZURE_EMBEDDING_DEPLOYMENT", ""),
        }
        missing = [key for key, value in required.items() if not value]
        if missing:
            raise ValueError(f"Missing required environment settings: {', '.join(missing)}")

        model_endpoint = required["AZURE_MODEL_ENDPOINT"].rstrip("/")
        parsed_endpoint = urlparse(model_endpoint)
        if (
            "<" in model_endpoint
            or ">" in model_endpoint
            or parsed_endpoint.scheme != "https"
            or not parsed_endpoint.hostname
        ):
            raise ValueError(
                "AZURE_MODEL_ENDPOINT must be the HTTPS inference endpoint for a deployed, "
                "Azure OpenAI-compatible model. Replace the placeholder in .env."
            )

        dimensions = int(os.getenv("AZURE_EMBEDDING_DIMENSIONS", "1536"))
        if dimensions < 1:
            raise ValueError("AZURE_EMBEDDING_DIMENSIONS must be positive")

        safety_endpoint = os.getenv("AZURE_CONTENT_SAFETY_ENDPOINT", "").rstrip("/")
        if safety_endpoint:
            parsed_safety_endpoint = urlparse(safety_endpoint)
            if parsed_safety_endpoint.scheme != "https" or not parsed_safety_endpoint.hostname:
                raise ValueError("AZURE_CONTENT_SAFETY_ENDPOINT must be an HTTPS endpoint")

        safety_threshold = int(os.getenv("AZURE_CONTENT_SAFETY_THRESHOLD", "2"))
        if not 0 <= safety_threshold <= 6:
            raise ValueError("AZURE_CONTENT_SAFETY_THRESHOLD must be between 0 and 6")

        return cls(
            managed_identity_client_id=os.getenv("AZURE_CLIENT_ID", ""),
            foundry_project_endpoint=os.getenv("FOUNDRY_PROJECT_ENDPOINT", ""),
            storage_account_url=required["AZURE_STORAGE_ACCOUNT_URL"],
            source_container=os.getenv("AZURE_SOURCE_CONTAINER", "source-documents"),
            search_endpoint=required["AZURE_SEARCH_ENDPOINT"],
            search_index=os.getenv("AZURE_SEARCH_INDEX", "architecture-policies"),
            model_endpoint=model_endpoint,
            chat_deployment=required["AZURE_CHAT_DEPLOYMENT"],
            embedding_deployment=required["AZURE_EMBEDDING_DEPLOYMENT"],
            openai_api_version=os.getenv("AZURE_OPENAI_API_VERSION", "2025-04-01-preview"),
            embedding_dimensions=dimensions,
            content_safety_endpoint=safety_endpoint,
            content_safety_threshold=safety_threshold,
        )