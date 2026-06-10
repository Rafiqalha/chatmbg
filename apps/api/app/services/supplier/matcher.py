import structlog
from app.dependencies import get_supabase_service

log = structlog.get_logger()


async def search_suppliers(
    lat: float | None = None,
    lon: float | None = None,
    radius_km: int = 20,
    category: str | None = None,
    verified_only: bool = False,
    query: str | None = None,
    limit: int = 20,
) -> list[dict]:
    supabase = get_supabase_service()

    if lat is not None and lon is not None:
        try:
            res = supabase.rpc(
                "find_nearby_suppliers",
                {
                    "sppg_lat": lat,
                    "sppg_lon": lon,
                    "radius_km": radius_km,
                    "category": category,
                    "min_cap": None,
                },
            ).execute()
            rows = res.data or []
            if rows:
                return [
                    {
                        "id": r["supplier_id"],
                        "name": r["org_name"],
                        "distance_km": float(r["distance_km"]),
                        "categories": r.get("categories") or [],
                        "capacity": r.get("capacity"),
                        "verified": r.get("is_verified", False),
                        "score": float(r.get("score") or 0),
                    }
                    for r in rows[:limit]
                ]
        except Exception as e:
            log.warning("Geospatial search failed", error=str(e))

    q = (
        supabase.table("suppliers")
        .select(
            "id, product_categories, daily_capacity_servings, is_verified, "
            "profile_completeness_pct, organizations(name, city, district)"
        )
        .eq("is_active", True)
        .limit(limit)
    )
    if verified_only:
        q = q.eq("is_verified", True)

    res = q.execute()
    items = []
    for row in res.data or []:
        org = row.get("organizations") or {}
        name = org.get("name") or "Supplier UMKM"
        if query and query.lower() not in name.lower():
            cats = row.get("product_categories") or []
            if not any(query.lower() in (c or "").lower() for c in cats):
                continue
        items.append({
            "id": row["id"],
            "name": name,
            "city": org.get("city"),
            "district": org.get("district"),
            "distance_km": None,
            "categories": row.get("product_categories") or [],
            "capacity": row.get("daily_capacity_servings"),
            "verified": row.get("is_verified", False),
            "score": (row.get("profile_completeness_pct") or 0) / 100,
        })
    return items
