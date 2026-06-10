import pytest

from app.services.nutrition.calculator import validate_menu


@pytest.mark.asyncio
async def test_validate_menu_with_mocked_parse(monkeypatch):
    async def fake_parse(menu_text):
        return [{"food_name": "nasi putih", "amount_g": 200}]

    async def fake_lookup(food_name, amount_g, supabase):
        return {
            "food_name": "nasi putih",
            "amount_g": amount_g,
            "energi_kkal": 350.0,
            "protein_g": 7.0,
            "lemak_g": 1.0,
            "karbohidrat_g": 76.0,
            "serat_g": 0.0,
        }

    monkeypatch.setattr(
        "app.services.nutrition.calculator.parse_menu_with_ai",
        fake_parse,
    )
    monkeypatch.setattr(
        "app.services.nutrition.calculator.lookup_nutrition",
        fake_lookup,
    )

    result = await validate_menu("nasi putih 200g", "sd")
    assert result["score"] >= 0
    assert len(result["nutrients"]) == 4
    assert result["status"] in ("memenuhi", "kurang", "tidak_memenuhi")
