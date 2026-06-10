import time
from fastapi import HTTPException
from app.config import settings

# In-memory store for rate limiting (for MVP/Dev)
# In production, use Redis.
_RATE_LIMITS = {}

async def check_rate_limit(user_id: str):
    now = time.time()
    
    if user_id not in _RATE_LIMITS:
        _RATE_LIMITS[user_id] = []
        
    # Remove older requests
    window_start = now - 60
    _RATE_LIMITS[user_id] = [t for t in _RATE_LIMITS[user_id] if t > window_start]
    
    if len(_RATE_LIMITS[user_id]) >= settings.DEFAULT_RATE_LIMIT_PER_MIN:
        raise HTTPException(status_code=429, detail="Rate limit exceeded. Please try again later.")
        
    _RATE_LIMITS[user_id].append(now)
