from __future__ import annotations

import re
import hashlib
from dataclasses import dataclass


@dataclass(frozen=True)
class Chunk:
    source: str
    index: int
    content: str


def make_document_id(source: str, index: int) -> str:
    """Return a deterministic Search-safe key for a source chunk."""
    return hashlib.sha256(f"{source}\0{index}".encode("utf-8")).hexdigest()


def chunk_markdown(source: str, text: str, max_chars: int = 1800) -> list[Chunk]:
    """Split Markdown on paragraph boundaries and hard-split oversized paragraphs."""
    if max_chars < 1:
        raise ValueError("max_chars must be positive")

    paragraphs = [re.sub(r"\s+", " ", part).strip() for part in re.split(r"\n\s*\n", text)]
    paragraphs = [part for part in paragraphs if part]
    pieces: list[str] = []
    for paragraph in paragraphs:
        while len(paragraph) > max_chars:
            split_at = paragraph.rfind(" ", 0, max_chars + 1)
            if split_at <= 0:
                split_at = max_chars
            pieces.append(paragraph[:split_at].strip())
            paragraph = paragraph[split_at:].strip()
        if paragraph:
            pieces.append(paragraph)

    chunks: list[str] = []
    current = ""
    for piece in pieces:
        candidate = f"{current}\n\n{piece}" if current else piece
        if len(candidate) > max_chars and current:
            chunks.append(current)
            current = piece
        else:
            current = candidate
    if current:
        chunks.append(current)

    return [Chunk(source=source, index=index, content=content) for index, content in enumerate(chunks)]


def estimate_monthly_cost(
    *,
    search_tier: str = "free",
    search_hours: int = 730,
    blob_gb: float = 0,
    safety_text_records: int = 0,
    log_ingestion_gb: float = 0,
) -> dict[str, float]:
    """Illustrative Central US retail estimate; model inference is intentionally excluded."""
    if search_hours < 0 or blob_gb < 0 or safety_text_records < 0 or log_ingestion_gb < 0:
        raise ValueError("Usage values cannot be negative")

    search_hourly = {"free": 0.0, "basic": 0.101}
    if search_tier not in search_hourly:
        raise ValueError("search_tier must be 'free' or 'basic'")

    lines = {
        "search": search_hourly[search_tier] * search_hours,
        "blob_storage": 0.0184 * blob_gb,
        "content_safety": max(0, safety_text_records - 5000) / 1000 * 0.38,
        "log_ingestion": 2.76 * log_ingestion_gb,
    }
    lines["estimated_total"] = sum(lines.values())
    return {name: round(amount, 4) for name, amount in lines.items()}