import pytest
from app.services.supplier.matcher import search_suppliers

@pytest.mark.asyncio
async def test_search_suppliers_by_category(monkeypatch):
    class FakeResult:
        def __init__(self, data):
            self.data = data
    
    class FakeQuery:
        def __init__(self, data):
            self._data = data
        def select(self, *a, **k): return self
        def eq(self, *a, **k): return self
        def limit(self, *a, **k): return self
        def execute(self): return FakeResult(self._data)
    
    class FakeSupabase:
        def table(self, name):
            return FakeQuery([
                {
                    "id": "1",
                    "product_categories": ["sayur", "buah"],
                    "daily_capacity_servings": 500,
                    "is_verified": True,
                    "profile_completeness_pct": 100,
                    "organizations": {"name": "Sayur Segar", "city": "Jakarta", "district": "Tebet"}
                }
            ])
            
    monkeypatch.setattr("app.services.supplier.matcher.get_supabase_service", lambda: FakeSupabase())
    
    results = await search_suppliers(query="sayur")
    assert len(results) == 1
    assert results[0]["name"] == "Sayur Segar"
    assert results[0]["verified"] is True
