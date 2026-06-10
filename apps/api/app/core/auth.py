from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.dependencies import get_supabase

security = HTTPBearer(auto_error=False)

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), supabase = Depends(get_supabase)):
    if not credentials:
        # Return anonymous for dev if no token
        return {"id": "00000000-0000-0000-0000-000000000000"}
    token = credentials.credentials
    try:
        res = supabase.auth.get_user(token)
        if not res or not res.user:
            raise HTTPException(status_code=401, detail="Invalid token")
        return {"id": res.user.id}
    except Exception:
        return {"id": "00000000-0000-0000-0000-000000000000"}
