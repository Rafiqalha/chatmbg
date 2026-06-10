# MBGBrain — AI Intelligence untuk Program Makan Bergizi Gratis Indonesia

**MBGBrain** adalah platform SaaS berbasis kecerdasan buatan yang berfungsi sebagai *intelligence infrastructure* untuk ekosistem program **Makan Bergizi Gratis (MBG)** Indonesia — inisiatif strategis nasional dengan anggaran Rp 71 triliun/tahun.

> "Dari ragu-ragu menjadi yakin — validasi menu, regulasi, dan supplier dalam satu platform."

## Daftar Isi

- [Latar Belakang & Masalah](#latar-belakang--masalah)
- [Fitur Utama](#fitur-utama)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Tech Stack](#tech-stack)
- [Struktur Monorepo](#struktur-monorepo)
- [Target Pengguna](#target-pengguna)
- [Model Monetisasi](#model-monetisasi)
- [Roadmap](#roadmap)
- [Getting Started](#getting-started)
- [Development](#development)

---

## Latar Belakang & Masalah

Program Makan Bergizi Gratis (MBG) dioperasikan melalui **Satuan Pelayanan Pemenuhan Gizi (SPPG)** yang tersebar di seluruh Indonesia. Setiap SPPG bertanggung jawab atas perencanaan menu, pengadaan bahan pangan dari UMKM lokal, distribusi, dan pelaporan kepatuhan.

### Permasalahan di Lapangan

| Masalah | Dampak |
|---|---|
| Regulasi MBG (SK 244, Perpres 83, standar gizi) tersebar dan sulit diakses | Operator SPPG sering tidak tahu pembaruan aturan |
| Tidak ada alat validasi menu otomatis | Risiko ketidaksesuaian gizi dan temuan audit |
| Proses matching SPPG-UMKM masih manual & informal | Inefisiensi rantai pasok, potensi markup harga |
| Pelaporan audit memakan waktu 2–3 hari per SPPG | Beban administrasi tinggi, rawan human error |
| Pengetahuan domain terfragmentasi | Tidak ada sumber terpercaya yang terintegrasi |

**MBGBrain hadir untuk menjembatani kesenjangan ini dengan AI yang memahami domain MBG secara mendalam.**

---

## Fitur Utama

### 1. MBG Regulatory Assistant (AI Chatbot)

Antarmuka percakapan untuk bertanya tentang regulasi, prosedur, dan panduan operasional MBG. Berbasis **Retrieval-Augmented Generation (RAG)** dengan knowledge corpus eksklusif.

- Jawab pertanyaan Bahasa Indonesia (formal & informal)
- Setiap jawaban disertai **citation** ke sumber regulasi (nama, pasal, kutipan)
- Deteksi pertanyaan di luar domain MBG
- Konteks percakapan 10+ giliran

### 2. Nutrition Menu Validator

Validasi rencana menu terhadap standar gizi Kemenkes secara otomatis.

- Input teks bebas (contoh: "nasi putih 200g, ayam goreng 75g, tempe orek 50g")
- Kalkulasi nilai gizi berbasis **TKPI** (Tabel Komposisi Pangan Indonesia)
- Dukungan 4 kelompok penerima: SD, SMP, Balita, Ibu Hamil/Menyusui
- Output: status compliance, rincian gizi, rekomendasi substitusi
- Ekspor hasil ke PDF

### 3. SK 244 Compliance Checker

Validasi rencana pengadaan supplier/bahan pangan terhadap persyaratan **SK Kepala BGN No. 244/2025**.

- Checklist persyaratan hyperlocal sourcing
- Penjelasan plain-language untuk setiap persyaratan
- Laporan compliance siap audit
- Panduan tindak lanjut untuk persyaratan belum terpenuhi

### 4. UMKM Supplier Directory & Matching

Direktori supplier lokal yang terverifikasi dengan rekomendasi berbasis lokasi.

- Pendaftaran profil UMKM mandiri (nama usaha, produk, kapasitas, lokasi)
- Pencarian SPPG dengan filter: jenis produk, radius lokasi, kapasitas
- Geospatial matching (PostGIS) — temukan supplier < 20 km dari SPPG
- Indikator kelengkapan profil dan status verifikasi

### 5. REST API Publik

Integrasikan intelligence MBG ke sistem pihak ketiga.

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/api/v1/chat` | POST | Query AI chatbot regulasi MBG |
| `/api/v1/validate-menu` | POST | Validasi nilai gizi menu |
| `/api/v1/compliance-check` | POST | Cek kepatuhan SK 244 |
| `/api/v1/suppliers/search` | GET | Cari supplier UMKM |
| `/api/v1/regulations/latest` | GET | Regulasi MBG terbaru |

---

## Arsitektur Sistem

```
User (Browser/API Client)
        │
        ▼
[Next.js Frontend / API Client]
        │
        ▼
[FastAPI Backend]
    ├── Auth Middleware (Supabase JWT)
    ├── Rate Limiter
    │
    ├── /chat ──────────────► [RAG Pipeline]
    │                              │
    │                    ┌─────────┴──────────┐
    │                    ▼                    ▼
    │           [Query Embedding]    [Context Retrieval]
    │           (OpenAI Embed)       (pgvector similarity search)
    │                    │                    │
    │                    └─────────┬──────────┘
    │                              ▼
    │                    [Prompt Construction]
    │                              │
    │                              ▼
    │                    [Claude API Call]
    │                              │
    │                              ▼
    │                    [Response + Citation]
    │
    ├── /validate-menu ──► [Nutrition Calculator]
    │                      (TKPI Database + Gizi Standards)
    │
    ├── /compliance-check ► [Regulation Rules Engine]
    │                        (SK 244 Checklist Logic)
    │
    └── /suppliers ────────► [PostgreSQL Query]
                             (Geospatial + Full-text search)
```

### RAG Pipeline Detail

1. **Ingestion** (offline): Regulasi PDF → text extraction → chunking (512 token) → embedding (OpenAI) → store ke pgvector
2. **Retrieval** (runtime): Query → embedding → cosine similarity search → re-ranking
3. **Generation** (runtime): System prompt + retrieved context → Claude API → response + citations

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| **Frontend** | Next.js 14 (App Router), Tailwind CSS, TypeScript |
| **Mobile** | Flutter (post-MVP) |
| **Backend** | FastAPI (Python 3.11+) |
| **Database** | PostgreSQL via Supabase |
| **Vector DB** | pgvector (terintegrasi PostgreSQL) |
| **LLM** | Anthropic Claude (claude-sonnet-4) |
| **Embedding** | OpenAI text-embedding-3-small |
| **Auth** | Supabase Auth |
| **Storage** | Supabase Storage |
| **Deployment** | Vercel (frontend) + Railway (backend) |
| **Monitoring** | Sentry |

---

## Struktur Monorepo

```
mbgbrain/
├── apps/
│   ├── web/              # Next.js 14 (frontend utama)
│   ├── mobile/           # Flutter (mobile app)
│   └── api/              # FastAPI (backend)
├── packages/
│   ├── ui/               # shared design system
│   ├── types/            # shared TypeScript types
│   └── config/           # shared ESLint, Tailwind config
├── supabase/
│   ├── migrations/       # SQL migration files (8 file)
│   ├── seed/             # seed data development
│   └── functions/        # Edge Functions (match_documents)
├── scripts/
│   ├── ingest/           # pipeline ingesti dokumen regulasi
│   └── eval/             # evaluasi akurasi RAG
└── docs/
    ├── api/              # dokumentasi API
    └── architecture/     # diagram arsitektur
```

---

## Target Pengguna

| Segmen | Persona | Kebutuhan |
|---|---|---|
| **SPPG** (Primary) | Ibu Ratna, Koordinator SPPG | Validasi menu, cek regulasi, matching supplier, laporan audit |
| **UMKM** (Secondary) | Pak Hendra, Pemilik Katering | Profil usaha, discovery oleh SPPG, panduan persyaratan |
| **Dinas** (Enterprise) | Dr. Andi, Kepala Dinkes | Dashboard kepatuhan, alert, laporan eksekutif |
| **Developer** (API) | Rizky, CTO Startup | REST API intelligence MBG |

---

## Model Monetisasi

| Tier | Harga | Fitur |
|---|---|---|
| **Free** | Gratis | 50 query/bulan, chatbot regulasi saja |
| **Pro SPPG** | Rp 299rb/bln (Early Bird) → Rp 499rb/bln | Unlimited chat + validator + compliance + supplier + PDF |
| **API** | Rp 50/query atau Rp 1,5jt/bln (30k query) | Full API access, webhook, SLA 99,5% |
| **Enterprise** | Negosiasi Rp 15–50jt/tahun | White-label dashboard, SSO, dedicated support |

---

## Roadmap

| Fase | Timeline | Target |
|---|---|---|
| **Fase 1: Fondasi** | Hari 1–15 | Knowledge corpus + RAG pipeline MVP + auth + baseline akurasi >80% |
| **Fase 2: MVP Build** | Hari 16–35 | Web app 3 modul + supplier directory + REST API + landing page + 2 SPPG pilot |
| **Fase 3: Traction** | Hari 36–60 | 5 SPPG aktif + case study + konversi paid + knowledge corpus v2 |
| **Fase 4: Mobile** | Hari 35–60 (paralel) | Flutter app (chat, validator, compliance, suppliers) |
| **Fase 5: Scale** | 3–12 bulan | Ekspansi Jawa → nasional, enterprise dashboard, integrasi e-procurement |

---

## Getting Started

### Prerequisites

- Node.js >= 18
- pnpm >= 8
- Python >= 3.11
- Flutter >= 3.x (untuk mobile)

### Setup

```bash
# Install dependencies
pnpm install

# Setup environment
cp .env.example .env
# Edit .env dengan credentials Supabase + API keys

# Setup database
supabase db push

# Ingest regulasi
cd scripts/ingest
python ingest_regulations.py --file samples/sk244_excerpt.txt --code SK_244_2025 --title "SK Kepala BGN No. 244 Tahun 2025" --date 2025-06-01
```

### Running Apps

```bash
# Web (Next.js)
pnpm --filter web dev          # → http://localhost:3000

# API (FastAPI)
cd apps/api
uvicorn main:app --reload      # → http://localhost:8000/docs

# Mobile (Flutter)
cd apps/mobile
flutter run
```

### Testing

```bash
# Backend tests
cd apps/api
pytest tests/ -v --asyncio-mode=auto

# Evaluasi akurasi RAG
python scripts/eval/eval_rag.py
```

---

## Environment Variables

| Variable | Deskripsi |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anon key (client-side) |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (server-side) |
| `SUPABASE_DB_URL` | Direct PostgreSQL connection string |
| `ANTHROPIC_API_KEY` | Claude API key |
| `OPENAI_API_KEY` | OpenAI API key (embedding) |
| `NEXT_PUBLIC_API_URL` | FastAPI backend URL |
| `SENTRY_DSN` | Sentry error tracking |

---

## Dokumentasi

- [PRD Lengkap](./PRD.md) — Product Requirements Document v1.0.0
- [AGENTS.md](./AGENTS.md) — Execution playbook for AI agent
- API Docs: `http://localhost:8000/docs` (Swagger) atau `http://localhost:8000/redoc`

---

## Lisensi

Proyek ini bersifat **confidential** — hak cipta © 2026 MBGBrain.
