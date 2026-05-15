"""
MBGBrain API — FastAPI Backend
Entry point utama untuk backend MBGBrain.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="MBGBrain API",
    description="AI Intelligence API untuk Program Makan Bergizi Gratis",
    version="0.1.0",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "MBGBrain API is running", "version": "0.1.0"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
