# MBGBrain — AI Intelligence untuk Program Makan Bergizi Gratis

> Platform AI untuk SPPG, UMKM, dan ekosistem Makan Bergizi Gratis Indonesia.

## Struktur Monorepo

```
mbgbrain/
├── apps/
│   ├── web/          → Next.js 14 (frontend utama)
│   ├── mobile/       → Flutter (mobile app)
│   └── api/          → FastAPI (backend)
├── packages/
│   ├── ui/           → shared design system
│   ├── types/        → shared TypeScript types
│   └── config/       → shared ESLint, Tailwind config
├── supabase/
│   ├── migrations/   → SQL migration files
│   ├── seed/         → seed data untuk development
│   └── functions/    → Supabase Edge Functions
├── scripts/
│   ├── ingest/       → pipeline ingesti dokumen regulasi
│   └── eval/         → evaluasi akurasi RAG
└── docs/
    ├── api/          → dokumentasi API (OpenAPI)
    └── architecture/ → diagram arsitektur
```

## Getting Started

### Prerequisites
- Node.js >= 18
- pnpm >= 8
- Python >= 3.11
- Flutter >= 3.x

### Setup
```bash
pnpm install
```

### Running Apps
```bash
# Web (Next.js)
pnpm --filter web dev

# API (FastAPI)
cd apps/api && source .venv/bin/activate && uvicorn main:app --reload

# Mobile (Flutter)
cd apps/mobile && flutter run
```
