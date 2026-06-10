from fastapi import APIRouter

from app.api.v1 import chat, compliance, regulations, suppliers, validate_menu, auth

api_router = APIRouter()
api_router.include_router(chat.router)
api_router.include_router(validate_menu.router)
api_router.include_router(compliance.router)
api_router.include_router(suppliers.router)
api_router.include_router(regulations.router)
api_router.include_router(auth.router)
