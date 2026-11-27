from __future__ import annotations

import json
from pathlib import Path

from azure.search.documents import SearchClient
from azure.search.documents.models import VectorizedQuery

from rag_agent.azure_services import build_credential, build_model_client
from rag_agent.settings import Settings


def main() -> None:
    settings = Settings.from_env()
    credential = build_credential(settings)
    cases = [json.loads(line) for line in Path("evaluation/golden_questions.jsonl").read_text(encoding="utf-8").splitlines()]
    model_client = build_model_client(settings, credential)
    embeddings = model_client.embeddings.create(
        model=settings.embedding_deployment,
        input=[case["question"] for case in cases],
    )
    vectors = [item.embedding for item in sorted(embeddings.data, key=lambda item: item.index)]
    search_client = SearchClient(settings.search_endpoint, settings.search_index, credential)
    hits = 0
    reciprocal_rank_sum = 0.0
    term_coverage_sum = 0.0

    for case, vector in zip(cases, vectors, strict=True):
        vector_query = VectorizedQuery(vector=vector, k_nearest_neighbors=5, fields="content_vector")
        results = list(
            search_client.search(
                search_text=case["question"],
                vector_queries=[vector_query],
                select=["content", "source", "chunk_index"],
                top=5,
            )
        )
        rank = next((index for index, result in enumerate(results, start=1) if result.get("source") == case["expected_source"]), None)
        retrieved_text = " ".join(str(result.get("content", "")) for result in results).casefold()
        matched_terms = sum(term.casefold() in retrieved_text for term in case["expected_terms"])
        term_coverage_sum += matched_terms / len(case["expected_terms"])
        if rank:
            hits += 1
            reciprocal_rank_sum += 1 / rank
        print(f"{case['id']}: {'hit@5' if rank else 'miss@5'} expected={case['expected_source']} rank={rank}")

    count = len(cases)
    print(f"Recall@5: {hits / count:.3f}")
    print(f"MRR@5: {reciprocal_rank_sum / count:.3f}")
    print(f"Expected-term coverage@5: {term_coverage_sum / count:.3f}")


if __name__ == "__main__":
    main()