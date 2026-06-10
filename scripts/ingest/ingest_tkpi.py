"""
Script ingesti data TKPI ke Supabase.
Jalankan: python scripts/ingest/ingest_tkpi.py --file path/to/TKPI.xlsx
"""
import argparse
import asyncio
import os
import sys
from pathlib import Path

import pandas as pd
import structlog
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "apps" / "api"))
load_dotenv(ROOT / ".env")

log = structlog.get_logger()

async def ingest_tkpi(excel_path: str):
    from supabase import create_client
    
    supabase = create_client(
        os.getenv("SUPABASE_URL"),
        os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
    )
    
    log.info("Reading Excel file", path=excel_path)
    try:
        df = pd.read_excel(excel_path)
    except Exception as e:
        log.error("Failed to read Excel", error=str(e))
        return
    
    # Menyiapkan kolom standar
    # Asumsikan kolom Excel: Kode, Nama Pangan, Kategori, Energi (Kal), Protein (g), Lemak (g), Karbohidrat (g), Serat (g), dll.
    records = []
    
    for _, row in df.iterrows():
        try:
            # Sesuaikan dengan nama kolom aktual di file Excel, ini contoh fallback
            nama_pangan = str(row.get("Nama Pangan", row.get("Nama", "Unknown")))
            kategori = str(row.get("Kategori", row.get("Golongan", "Umum")))
            
            record = {
                "kode_pangan": str(row.get("Kode", "")).strip(),
                "nama_pangan": nama_pangan.strip(),
                "kategori": kategori.strip(),
                "energi_kkal": float(row.get("Energi (Kal)", row.get("Energi", 0)) or 0),
                "protein_g": float(row.get("Protein (g)", row.get("Protein", 0)) or 0),
                "lemak_g": float(row.get("Lemak (g)", row.get("Lemak", 0)) or 0),
                "karbohidrat_g": float(row.get("Karbohidrat (g)", row.get("Karbohidrat", 0)) or 0),
                "serat_g": float(row.get("Serat (g)", row.get("Serat", 0)) or 0),
            }
            records.append(record)
        except Exception as e:
            log.warning("Skip row", error=str(e), row=row.to_dict())
            
    log.info("Parsed records", count=len(records))
    
    for i in range(0, len(records), 100):
        batch = records[i:i+100]
        try:
            supabase.table("food_items").upsert(batch, on_conflict="kode_pangan").execute()
            log.info("Inserted batch", start=i, count=len(batch))
        except Exception as e:
            log.error("Failed to insert batch", error=str(e))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest TKPI Excel to Supabase")
    parser.add_argument("--file", required=True, help="Path to TKPI Excel file")
    args = parser.parse_args()
    
    asyncio.run(ingest_tkpi(args.file))
