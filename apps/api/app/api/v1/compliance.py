from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.core.auth import get_current_user
from app.services.compliance.sk244 import run_sk244_check

router = APIRouter(tags=["Compliance"])


class ComplianceRequest(BaseModel):
    check_type: str = Field(default="sk244_supplier")
    inputs: dict = Field(default_factory=dict)


@router.post("/compliance-check")
async def compliance_check(
    req: ComplianceRequest,
    user: dict = Depends(get_current_user),
):
    if req.check_type.startswith("sk244"):
        return run_sk244_check(req.inputs)
    return {
        "check_type": req.check_type,
        "overall_status": "kurang",
        "score": 0,
        "items": [],
        "recommendations": ["Tipe pemeriksaan belum didukung"],
    }
