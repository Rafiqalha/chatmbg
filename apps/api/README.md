# MBGBrain API — FastAPI Backend

Backend API untuk platform MBGBrain.

## Setup
```bash
cd apps/api
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/Mac:
source .venv/bin/activate

pip install -r requirements.txt
```

## Run
```bash
uvicorn main:app --reload --port 8000
```
