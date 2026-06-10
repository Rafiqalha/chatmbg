import json

import pytest
from httpx import ASGITransport, AsyncClient

from main import app


@pytest.mark.asyncio
async def test_health():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


@pytest.mark.asyncio
async def test_chat_endpoint_returns_sse(monkeypatch):
    async def fake_pipeline(message, module="chat", stream=True):
        yield f"data: {json.dumps({'delta': 'Jawaban uji'})}\n\n"
        yield "data: [DONE]\n\n"

    monkeypatch.setattr("app.api.v1.chat.run_rag_pipeline", fake_pipeline)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/chat",
            json={"message": "Apa itu hyperlocal sourcing?"},
        )

    assert response.status_code == 200
    assert "text/event-stream" in response.headers.get("content-type", "")
    body = response.text
    assert "Jawaban uji" in body or "data:" in body


@pytest.mark.asyncio
async def test_menu_validator(monkeypatch):
    async def fake_parse(menu_text):
        return [
            {"food_name": "nasi putih", "amount_g": 200},
            {"food_name": "ayam daging", "amount_g": 100},
        ]

    async def fake_lookup(food_name, amount_g, supabase):
        return {
            "food_name": food_name,
            "amount_g": amount_g,
            "energi_kkal": 350.0,
            "protein_g": 20.0,
            "lemak_g": 10.0,
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

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/validate-menu",
            json={
                "menu": "nasi putih 200g, ayam 100g",
                "recipient_group": "sd",
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] in ("memenuhi", "kurang", "tidak_memenuhi")
    assert "nutrients" in data
    assert 0 <= data["score"] <= 100


@pytest.mark.asyncio
async def test_compliance_check():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/compliance-check",
            json={
                "check_type": "sk244_supplier",
                "inputs": {
                    "has_nib": True,
                    "has_halal_cert": True,
                    "has_contract": True,
                    "bpom_compliant": True,
                    "supplier_same_district": True,
                    "daily_capacity": 500,
                    "required_servings": 200,
                },
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["overall_status"] == "memenuhi"
    assert data["score"] >= 80


@pytest.mark.asyncio
async def test_regulations_latest(monkeypatch):
    class FakeResult:
        data = [
            {
                "id": "1",
                "title": "SK 244",
                "short_code": "SK_244_2025",
                "type": "sk",
                "issuer": "BGN",
                "effective_date": "2025-01-01",
                "version": "1.0",
                "summary": "Test",
            }
        ]

    class FakeQuery:
        def select(self, *a, **k):
            return self

        def eq(self, *a, **k):
            return self

        def order(self, *a, **k):
            return self

        def limit(self, *a, **k):
            return self

        def execute(self):
            return FakeResult()

    class FakeSupabase:
        def table(self, name):
            return FakeQuery()

    monkeypatch.setattr(
        "app.api.v1.regulations.get_supabase_service",
        lambda: FakeSupabase(),
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/regulations/latest")

    assert response.status_code == 200
    assert len(response.json()["regulations"]) == 1
