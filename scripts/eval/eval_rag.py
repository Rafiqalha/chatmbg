"""
Evaluasi akurasi RAG terhadap soal domain MBG.
Jalankan: python scripts/eval/eval_rag.py
"""
import argparse
import asyncio
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "apps" / "api"))

from dotenv import load_dotenv

load_dotenv(ROOT / ".env")

from app.services.rag.pipeline import run_rag_pipeline


def load_questions(path: Path) -> list[dict]:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    return data.get("questions", [])


def score_answer(text: str, keywords: list[str]) -> bool:
    lower = text.lower()
    hits = sum(1 for kw in keywords if kw.lower() in lower)
    return hits >= max(1, len(keywords) // 2)


async def evaluate(questions: list[dict]) -> dict:
    results = []
    passed = 0

    for i, item in enumerate(questions, 1):
        q = item["q"]
        keywords = item.get("keywords", [])
        full_text = ""

        async for chunk in run_rag_pipeline(q, module="chat"):
            if chunk.startswith("data: ") and chunk.strip() != "data: [DONE]":
                try:
                    payload = json.loads(chunk[6:].strip())
                    full_text += payload.get("delta", "")
                except json.JSONDecodeError:
                    pass

        ok = score_answer(full_text, keywords)
        if ok:
            passed += 1
        results.append({"question": q, "passed": ok, "answer_preview": full_text[:300]})
        print(f"[{i}/{len(questions)}] {'PASS' if ok else 'FAIL'} — {q[:60]}...")

    accuracy = (passed / len(questions) * 100) if questions else 0
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "total": len(questions),
        "passed": passed,
        "accuracy_pct": round(accuracy, 1),
        "results": results,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--questions",
        default=str(ROOT / "scripts" / "eval" / "questions.yaml"),
    )
    parser.add_argument(
        "--output",
        default=str(ROOT / "scripts" / "eval" / "results"),
    )
    args = parser.parse_args()

    questions = load_questions(Path(args.questions))
    report = asyncio.run(evaluate(questions))

    out_dir = Path(args.output)
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / f"eval_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    out_file.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"\nAccuracy: {report['accuracy_pct']}% ({report['passed']}/{report['total']})")
    print(f"Saved: {out_file}")


if __name__ == "__main__":
    main()
