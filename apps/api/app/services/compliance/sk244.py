"""Rules engine checklist SK 244 / kepatuhan supplier MBG."""

from typing import Any

SK244_ITEMS = [
    {
        "id": "hyperlocal",
        "title": "Hyperlocal sourcing",
        "regulation": "SK 244/2025",
        "evaluate": lambda i: bool(i.get("supplier_same_district") or i.get("supplier_same_city")),
    },
    {
        "id": "nib",
        "title": "NIB & legalitas usaha",
        "regulation": "SK 244/2025",
        "evaluate": lambda i: bool(i.get("has_nib")),
    },
    {
        "id": "halal",
        "title": "Sertifikat halal (jika berlaku)",
        "regulation": "SK 244/2025",
        "evaluate": lambda i: i.get("halal_na") or bool(i.get("has_halal_cert")),
    },
    {
        "id": "capacity",
        "title": "Kapasitas produksi memadai",
        "regulation": "SK 244/2025",
        "evaluate": lambda i: (i.get("daily_capacity") or 0) >= (i.get("required_servings") or 100),
    },
    {
        "id": "bpom",
        "title": "Standar keamanan pangan BPOM",
        "regulation": "Regulasi BPOM",
        "evaluate": lambda i: bool(i.get("bpom_compliant")),
    },
    {
        "id": "contract",
        "title": "Dokumen perjanjian kerja sama",
        "regulation": "SK 244/2025",
        "evaluate": lambda i: bool(i.get("has_contract")),
    },
]


def run_sk244_check(inputs: dict[str, Any]) -> dict:
    results = []
    passed = 0

    for item in SK244_ITEMS:
        ok = bool(item["evaluate"](inputs))
        if ok:
            passed += 1
        results.append({
            "id": item["id"],
            "title": item["title"],
            "regulation": item["regulation"],
            "status": "memenuhi" if ok else "tidak_memenuhi",
            "passed": ok,
        })

    total = len(SK244_ITEMS)
    score = int((passed / total) * 100) if total else 0

    if score >= 90:
        overall = "memenuhi"
    elif score >= 60:
        overall = "kurang"
    else:
        overall = "tidak_memenuhi"

    gaps = [r["title"] for r in results if not r["passed"]]

    return {
        "check_type": "sk244_supplier",
        "overall_status": overall,
        "score": score,
        "items": results,
        "passed_count": passed,
        "total_count": total,
        "recommendations": [
            f"Lengkapi: {title}" for title in gaps[:5]
        ],
        "regulation_version": "SK 244/2025",
    }
