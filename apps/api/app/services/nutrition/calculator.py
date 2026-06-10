import re
import structlog
from typing import Any
import json
from groq import AsyncGroq
from app.config import settings

log = structlog.get_logger()

NUTRITION_STANDARDS = {
    "sd": {
        "energi_kkal": (400, 600),
        "protein_g":   (15, None),
        "lemak_g":     (10, None),
        "karbohidrat_g": (60, None),
    },
    "smp": {
        "energi_kkal": (500, 700),
        "protein_g":   (18, None),
        "lemak_g":     (13, None),
        "karbohidrat_g": (75, None),
    },
    "balita": {
        "energi_kkal": (350, 500),
        "protein_g":   (13, None),
        "lemak_g":     (10, None),
        "karbohidrat_g": (55, None),
    },
    "bumil": {
        "energi_kkal": (600, 800),
        "protein_g":   (25, None),
        "lemak_g":     (15, None),
        "karbohidrat_g": (85, None),
    },
}

async def parse_menu_with_ai(menu_text: str) -> list[dict]:
    client = AsyncGroq(api_key=settings.GROQ_API_KEY)

    prompt = f"""Parse menu makanan berikut ke format JSON terstruktur.
Untuk setiap item makanan, ekstrak nama dan estimasi berat dalam gram.
Jika berat tidak disebutkan, gunakan porsi standar Indonesia.

Menu: {menu_text}

Respond ONLY dengan JSON array, tidak ada teks lain:
[{{"food_name": "nasi putih", "amount_g": 200}}, ...]"""

    try:
        response = await client.chat.completions.create(
            model=settings.GROQ_MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
            max_tokens=500,
        )
        content = response.choices[0].message.content
        # Try to find json array
        start = content.find("[")
        end = content.rfind("]")
        if start != -1 and end != -1:
            return json.loads(content[start:end+1])
        return json.loads(content)
    except Exception as e:
        log.error("AI parse menu error", error=str(e))
        return []

async def _find_food(supabase, food_name: str) -> dict | None:
    try:
        result = supabase.rpc(
            "search_food_by_name",
            {"query": food_name, "limit_n": 1},
        ).execute()
        if result.data:
            return result.data[0]
    except Exception:
        pass

    fallback = (
        supabase.table("food_items")
        .select("*")
        .ilike("nama_pangan", f"%{food_name}%")
        .limit(1)
        .execute()
    )
    if fallback.data:
        return fallback.data[0]
    return None


async def lookup_nutrition(food_name: str, amount_g: float, supabase) -> dict | None:
    try:
        food = await _find_food(supabase, food_name)
        if not food:
            return None
        ratio = amount_g / 100

        return {
            "food_name":     food["nama_pangan"],
            "amount_g":      amount_g,
            "energi_kkal":   round((food.get("energi_kkal") or 0) * ratio, 1),
            "protein_g":     round((food.get("protein_g")   or 0) * ratio, 1),
            "lemak_g":       round((food.get("lemak_g")     or 0) * ratio, 1),
            "karbohidrat_g": round((food.get("karbohidrat_g") or 0) * ratio, 1),
            "serat_g":       round((food.get("serat_g")     or 0) * ratio, 1),
        }
    except Exception as e:
        log.error("Lookup nutrition error", error=str(e))
        return None

async def validate_menu(menu_text: str, recipient_group: str) -> dict:
    from app.dependencies import get_supabase_service
    supabase = get_supabase_service()
    standards = NUTRITION_STANDARDS.get(recipient_group, NUTRITION_STANDARDS["sd"])

    items = await parse_menu_with_ai(menu_text)

    totals = {"energi_kkal": 0, "protein_g": 0, "lemak_g": 0, "karbohidrat_g": 0, "serat_g": 0}
    not_found = []

    for item in items:
        nutrition = await lookup_nutrition(item.get("food_name", ""), item.get("amount_g", 0), supabase)
        if nutrition:
            for key in totals:
                totals[key] += nutrition.get(key, 0)
        else:
            not_found.append(item.get("food_name", ""))

    nutrients = []
    overall_score = 0

    for nutrient, (min_val, max_val) in standards.items():
        actual = totals.get(nutrient, 0)
        pct = (actual / min_val * 100) if min_val else 100

        if pct >= 100:
            status = "memenuhi"
            score = 100
        elif pct >= 75:
            status = "kurang"
            score = int(pct)
        else:
            status = "tidak_memenuhi"
            score = int(pct)

        nutrients.append({
            "name":       nutrient.replace("_", " ").title().replace("Kkal", "kkal").replace("G", "g"),
            "value":      round(actual, 1),
            "unit":       "kkal" if "kkal" in nutrient else "g",
            "standard":   min_val,
            "percentage": round(pct, 1),
            "status":     status,
        })
        overall_score += score

    avg_score = overall_score // len(nutrients) if nutrients else 0

    if avg_score >= 90:   overall_status = "memenuhi"
    elif avg_score >= 65: overall_status = "kurang"
    else:                 overall_status = "tidak_memenuhi"

    suggestions = []
    for n in nutrients:
        if n["status"] == "kurang":
            suggestions.append(f"Tambah sumber {n['name'].lower()} — masih {100 - n['percentage']:.0f}% di bawah standar")
        elif n["status"] == "tidak_memenuhi":
            suggestions.append(f"⚠️ {n['name']} sangat kurang ({n['percentage']:.0f}% dari standar) — pertimbangkan penggantian bahan")

    if not_found:
        suggestions.append(f"Catatan: {', '.join(not_found)} tidak ditemukan di database TKPI — kalkulasi mungkin kurang akurat")

    return {
        "status":      overall_status,
        "score":       avg_score,
        "nutrients":   nutrients,
        "suggestions": suggestions,
        "regulation":  "Standar Gizi MBG — Kemenkes RI & Pedoman BGN 2025",
        "items_parsed": items,
    }
