from fastapi import APIRouter, Depends, Query, HTTPException
from pydantic import BaseModel, Field

from app.core.auth import get_current_user
from app.services.supplier.matcher import search_suppliers

router = APIRouter(tags=["Suppliers"])


@router.get("/suppliers/search")
async def suppliers_search(
    lat: float | None = Query(None),
    lon: float | None = Query(None),
    radius_km: int = Query(20, ge=1, le=100),
    category: str | None = Query(None),
    verified_only: bool = Query(False),
    q: str | None = Query(None),
    limit: int = Query(20, ge=1, le=50),
    user: dict = Depends(get_current_user),
):
    results = await search_suppliers(
        lat=lat,
        lon=lon,
        radius_km=radius_km,
        category=category,
        verified_only=verified_only,
        query=q,
        limit=limit,
    )
    return {"count": len(results), "suppliers": results}

class SupplierRegistrationRequest(BaseModel):
    org_name: str = Field(..., min_length=3)
    city: str
    district: str
    daily_capacity: int = Field(..., gt=0)
    categories: list[str]

@router.post("/suppliers/register")
async def register_supplier(
    req: SupplierRegistrationRequest,
    user: dict = Depends(get_current_user),
):
    from app.dependencies import get_supabase_service
    import structlog
    
    log = structlog.get_logger()
    supabase = get_supabase_service()
    
    try:
        # Create organization first
        org_res = supabase.table("organizations").insert({
            "name": req.org_name,
            "type": "umkm_supplier",
            "city": req.city,
            "district": req.district
        }).execute()
        
        org_id = org_res.data[0]["id"]
        
        # Create supplier profile
        supp_res = supabase.table("suppliers").insert({
            "org_id": org_id,
            "daily_capacity_servings": req.daily_capacity,
            "product_categories": req.categories,
            "is_verified": False,
            "profile_completeness_pct": 50
        }).execute()
        
        return {"status": "success", "supplier_id": supp_res.data[0]["id"]}
    except Exception as e:
        log.error("Failed to register supplier", error=str(e))
        raise HTTPException(status_code=400, detail="Failed to register supplier")
