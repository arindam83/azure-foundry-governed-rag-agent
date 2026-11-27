from __future__ import annotations

import argparse
from pathlib import Path

from .azure_services import build_credential, ingest_blob_documents, upload_local_documents
from .settings import Settings


def main() -> None:
    parser = argparse.ArgumentParser(description="Upload synthetic policy docs and build the Search vector index.")
    parser.add_argument("--docs", default="docs", help="Folder containing Markdown source documents")
    parser.add_argument("--skip-upload", action="store_true", help="Index Markdown files already present in Blob Storage")
    args = parser.parse_args()

    settings = Settings.from_env()
    credential = build_credential(settings)
    if not args.skip_upload:
        uploaded = upload_local_documents(settings, credential, args.docs)
        print(f"Uploaded {uploaded} Markdown files to {settings.source_container}")
    chunks = ingest_blob_documents(settings, credential, str(Path(args.docs)))
    print(f"Indexed {chunks} chunks in {settings.search_index}")


if __name__ == "__main__":
    main()