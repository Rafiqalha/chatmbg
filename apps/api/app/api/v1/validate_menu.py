from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from app.services.nutrition.calculator import validate_menu
from app.core.auth import get_current_user

router = APIRouter(tags=["Nutrition Validator"])

class MenuValidationRequest(BaseModel):
    menu: str = Field(..., min_length=3)
    recipient_group: str = "sd"

@router.post("/validate-menu")
async def validate_menu_endpoint(
    req: MenuValidationRequest,
    user: dict = Depends(get_current_user),
):
    result = await validate_menu(req.menu, req.recipient_group)
    return result
