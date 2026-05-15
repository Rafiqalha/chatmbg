# Product Requirements Document (PRD)
## MBGBrain — AI Intelligence Infrastructure for Indonesia's Makan Bergizi Gratis Program

| Field | Detail |
|---|---|
| **Versi** | 1.0.0 |
| **Status** | Draft — Pre-Development |
| **Tanggal** | 15 Mei 2026 |
| **Author** | Rafiq (Indie Developer / Product Owner) |
| **Klasifikasi** | Confidential |

---

## Daftar Isi

1. [Executive Summary](#1-executive-summary)
2. [Latar Belakang & Konteks](#2-latar-belakang--konteks)
3. [Pernyataan Masalah](#3-pernyataan-masalah)
4. [Visi & Misi Produk](#4-visi--misi-produk)
5. [Target Pengguna & Personas](#5-target-pengguna--personas)
6. [Tujuan Bisnis & Metrik Keberhasilan](#6-tujuan-bisnis--metrik-keberhasilan)
7. [Ruang Lingkup Produk](#7-ruang-lingkup-produk)
8. [Fitur & Persyaratan Fungsional](#8-fitur--persyaratan-fungsional)
9. [Persyaratan Non-Fungsional](#9-persyaratan-non-fungsional)
10. [Arsitektur Teknis](#10-arsitektur-teknis)
11. [Arsitektur Data & Knowledge Base](#11-arsitektur-data--knowledge-base)
12. [Model Monetisasi & Offer Architecture](#12-model-monetisasi--offer-architecture)
13. [Competitive Positioning](#13-competitive-positioning)
14. [Roadmap & Milestones](#14-roadmap--milestones)
15. [Asumsi & Ketergantungan](#15-asumsi--ketergantungan)
16. [Risiko & Mitigasi](#16-risiko--mitigasi)
17. [Kriteria Penerimaan (Definition of Done)](#17-kriteria-penerimaan-definition-of-done)
18. [Glosarium](#18-glosarium)

---

## 1. Executive Summary

**MBGBrain** adalah platform SaaS berbasis kecerdasan buatan yang berfungsi sebagai *intelligence infrastructure* untuk ekosistem program **Makan Bergizi Gratis (MBG)** Indonesia. Produk ini dirancang untuk menjawab kesenjangan kritis antara kompleksitas regulasi MBG dan kapasitas operasional pelaku di lapangan — mulai dari Satuan Pelayanan Pemenuhan Gizi (SPPG) hingga UMKM penyedia pangan.

Alih-alih membangun Large Language Model (LLM) dari nol, MBGBrain menggunakan pendekatan **Retrieval-Augmented Generation (RAG)** di atas LLM foundational yang sudah ada (Claude API / OpenAI), diperkaya dengan knowledge corpus MBG yang dibangun secara eksklusif dan terstruktur. Moat kompetitif produk ini terletak pada **kelengkapan data domain**, **akurasi kontekstual**, dan **jaringan adopsi** — bukan pada model AI-nya sendiri.

Produk ini menyasar tiga segmen utama secara bertahap: SPPG sebagai anchor user, UMKM/supplier sebagai secondary user, dan Dinas/instansi pemerintah sebagai enterprise user. Model monetisasi hybrid: SaaS subscription untuk SPPG + API pay-per-call untuk vendor dan mitra sistem.

---

## 2. Latar Belakang & Konteks

### 2.1 Program Makan Bergizi Gratis (MBG)

Program MBG adalah inisiatif strategis nasional yang diluncurkan oleh Pemerintah Indonesia di bawah kepemimpinan Presiden Prabowo Subianto. Program ini bertujuan menyediakan makanan bergizi gratis bagi siswa sekolah, balita, ibu hamil, dan ibu menyusui di seluruh Indonesia dengan anggaran yang diproyeksikan mencapai **Rp 71 triliun per tahun**.

Secara teknis, program ini dioperasikan melalui jaringan **Satuan Pelayanan Pemenuhan Gizi (SPPG)** yang tersebar di seluruh wilayah Indonesia. Setiap SPPG bertanggung jawab atas perencanaan menu, pengadaan bahan pangan dari UMKM lokal, distribusi, dan pelaporan kepatuhan kepada otoritas terkait.

### 2.2 Regulasi Kunci

Operasional MBG diatur oleh sejumlah peraturan yang saling berkaitan:

- **SK Kepala BGN No. 244 Tahun 2025** — mengatur mekanisme matching antara SPPG dan UMKM/supplier lokal, termasuk kewajiban hyperlocal sourcing.
- **Perpres No. 83 Tahun 2024** — dasar hukum penyelenggaraan program MBG secara nasional.
- **Standar Gizi Kemenkes** — batas nilai gizi (kalori, protein, lemak, karbohidrat, mikronutrien) yang harus dipenuhi setiap porsi sajian.
- **Regulasi BPOM** — standar keamanan pangan dan higienitas untuk dapur/katering yang berpartisipasi.
- **Pedoman BGN (Badan Gizi Nasional)** — juknis operasional SPPG, prosedur pelaporan, dan mekanisme audit.

### 2.3 Kesenjangan yang Ditemukan (Gap Analysis)

Meskipun regulasi sudah cukup komprehensif, terdapat kesenjangan implementasi yang signifikan di lapangan:

1. **Kesenjangan informasi regulasi**: Mayoritas operator SPPG tidak memiliki akses cepat dan terstruktur terhadap regulasi terkini. Pembaruan regulasi sering kali diketahui terlambat.

2. **Ketiadaan alat bantu kepatuhan**: Tidak ada tools digital yang secara spesifik membantu SPPG memvalidasi rencana menu terhadap standar gizi dan compliance SK 244.

3. **Proses matching SPPG-UMKM masih manual**: Hyperlocal matching yang diamanatkan SK 244 masih dilakukan melalui koordinasi informal, tanpa sistem yang dapat diandalkan.

4. **Beban administrasi tinggi**: Pelaporan audit ke Kemenpan/BPKP memerlukan dokumentasi yang rumit dan time-consuming bagi SPPG.

5. **Fragmentasi pengetahuan domain**: Tidak ada satu sumber terpercaya yang mengintegrasikan seluruh aspek pengetahuan MBG (regulasi + gizi + logistik + administrasi).

---

## 3. Pernyataan Masalah

### 3.1 Masalah Utama

> **"Program nasional senilai Rp 71 triliun dioperasikan dengan mekanisme koordinasi yang masih bergantung pada komunikasi informal, dokumen fisik, dan pengetahuan terfragmentasi — membuka ruang inefisiensi, ketidakpatuhan regulasi, dan pemborosan anggaran negara yang signifikan."**

### 3.2 Masalah Spesifik per Stakeholder

**SPPG / Satuan Pelayanan:**
- Kesulitan memahami dan mengikuti pembaruan regulasi yang kompleks dan sering berubah.
- Tidak ada tools untuk memvalidasi apakah menu yang direncanakan sudah memenuhi standar gizi yang ditetapkan.
- Proses dokumentasi dan pelaporan kepatuhan sangat memakan waktu dan rentan kesalahan.
- Sulitnya menemukan dan memverifikasi supplier UMKM lokal yang memenuhi syarat SK 244.

**UMKM / Supplier Pangan:**
- Tidak memahami persyaratan teknis untuk menjadi supplier resmi MBG.
- Tidak ada mekanisme discovery yang efisien untuk ditemukan oleh SPPG terdekat.
- Ketidakpastian dalam standar kualitas dan prosedur pengajuan.

**Dinas Kesehatan / Pemerintah Daerah:**
- Tidak ada dashboard real-time untuk memantau tingkat kepatuhan SPPG di wilayahnya.
- Sulit mengidentifikasi potensi masalah sebelum menjadi temuan audit.

**Masyarakat Umum:**
- Tidak ada sumber informasi terpercaya dan mudah diakses mengenai hak, mekanisme, dan progres program MBG.

---

## 4. Visi & Misi Produk

### 4.1 Visi

> **"Menjadi sistem kecerdasan operasional yang tidak terpisahkan dari ekosistem Makan Bergizi Gratis Indonesia — menjadikan setiap keputusan dalam program ini lebih cepat, lebih akurat, dan lebih dapat dipertanggungjawabkan."**

### 4.2 Misi

MBGBrain hadir untuk:
1. **Mendemokratisasi akses pengetahuan regulasi MBG** — siapapun, di manapun, dapat memperoleh panduan yang akurat dan up-to-date dalam hitungan detik.
2. **Mengeliminasi ketidakpatuhan yang tidak disengaja** — dengan validasi otomatis sebelum menu atau keputusan pengadaan dieksekusi.
3. **Mempercepat ekosistem SPPG-UMKM** — dengan matching berbasis kecerdasan yang menggantikan koordinasi informal.
4. **Membangun audit trail yang andal** — sehingga setiap rupiah anggaran MBG dapat dipertanggungjawabkan dengan dokumentasi yang solid.

### 4.3 Proposition Value Utama

| Segmen | Value Proposition |
|---|---|
| SPPG | "Dari ragu-ragu menjadi yakin — validasi menu, regulasi, dan supplier dalam satu platform" |
| UMKM | "Ditemukan oleh SPPG yang tepat, pada waktu yang tepat, dengan persyaratan yang jelas" |
| Pemerintah | "Visibilitas real-time atas kepatuhan program tanpa menambah beban pelaporan" |
| Developer/Vendor | "API intelligence MBG siap pakai — integrasikan ke sistem Anda dalam satu hari" |

---

## 5. Target Pengguna & Personas

### Persona 1 — Ibu Ratna, Koordinator SPPG (Primary User)

- **Demografi**: Perempuan, 35–50 tahun, PNS atau tenaga kontrak, berbasis di kecamatan/kabupaten.
- **Konteks**: Mengelola SPPG yang melayani 500–2.000 penerima manfaat per hari. Bertanggung jawab atas perencanaan menu mingguan, koordinasi dengan 3–8 supplier UMKM, dan pelaporan bulanan ke dinas.
- **Pain points**: Selalu khawatir rencana menu tidak comply standar gizi. Sering kewalahan ketika ada pembaruan regulasi. Laporan bulanan memakan waktu 2–3 hari.
- **Goals**: Menjalankan SPPG dengan lancar, lolos audit tanpa masalah, tidak direpotkan urusan teknis yang membuang waktu.
- **Tech literacy**: Sedang. Terbiasa WhatsApp dan Google Sheets, belum familiar dengan SaaS kompleks.
- **Kebutuhan produk**: Antarmuka sederhana, panduan langkah demi langkah, output laporan siap pakai.

### Persona 2 — Pak Hendra, Pemilik UMKM Katering (Secondary User)

- **Demografi**: Laki-laki, 30–45 tahun, pemilik usaha katering skala kecil-menengah di kabupaten/kota.
- **Konteks**: Sudah menjadi supplier MBG informal atau ingin mendaftar menjadi supplier resmi. Memiliki kapasitas produksi 200–1.000 porsi per hari.
- **Pain points**: Tidak tahu persyaratan teknis menjadi supplier resmi. Sulit menemukan SPPG yang membutuhkan suppliernya. Tidak ada jaminan kepastian order.
- **Goals**: Mendapatkan kontrak jangka panjang dengan SPPG, memahami standar yang harus dipenuhi, dan mengembangkan usaha.
- **Kebutuhan produk**: Profil usaha yang bisa ditemukan SPPG, panduan persyaratan supplier, notifikasi peluang matching.

### Persona 3 — Dr. Andi, Kepala Bidang Gizi Dinas Kesehatan (Enterprise User)

- **Demografi**: Pejabat pemerintah daerah, 40–55 tahun, berlatar belakang kesehatan/gizi.
- **Konteks**: Mengawasi implementasi MBG di 50–200 SPPG dalam satu kabupaten/kota. Bertanggung jawab ke Bupati/Walikota dan instansi pusat (BGN, Kemenkes).
- **Pain points**: Data kepatuhan SPPG tidak real-time. Laporan dari lapangan sering terlambat dan tidak konsisten. Sulit mengidentifikasi SPPG yang bermasalah sebelum audit.
- **Goals**: Visibilitas penuh atas program di wilayahnya, kemampuan intervensi dini, laporan yang mudah dikomunikasikan ke atasannya.
- **Kebutuhan produk**: Dashboard aggregasi, alert ketidakpatuhan, laporan eksekutif satu halaman.

### Persona 4 — Rizky, Developer Sistem Katering (API User)

- **Demografi**: Developer atau CTO di startup/perusahaan teknologi yang membangun sistem untuk ekosistem MBG.
- **Konteks**: Membutuhkan akses ke intelligence MBG (validasi gizi, cek regulasi, matching) tanpa harus membangunnya dari nol.
- **Pain points**: Tidak ada API publik yang menyediakan data dan logika domain MBG secara terstruktur.
- **Goals**: Integrasi cepat, dokumentasi yang jelas, SLA yang dapat diandalkan.
- **Kebutuhan produk**: REST API terstandarisasi, API key management, rate limiting transparan, webhook untuk update regulasi.

---

## 6. Tujuan Bisnis & Metrik Keberhasilan

### 6.1 Tujuan Bisnis

| Fase | Horizon | Tujuan |
|---|---|---|
| Validasi | 0–3 bulan | Membuktikan product-market fit dengan pengguna nyata di lapangan |
| Traction | 3–6 bulan | Menghasilkan revenue pertama dan membangun reputasi sebagai solusi rujukan |
| Scale | 6–18 bulan | Ekspansi ke seluruh Jawa, kemudian nasional; menarik minat investor/mitra |

### 6.2 Key Performance Indicators (KPI)

**Product Metrics:**

| Metrik | Target 30 Hari | Target 60 Hari | Target 90 Hari |
|---|---|---|---|
| SPPG pilot aktif | 2 | 5 | 15 |
| Query AI per bulan | 500 | 2.000 | 10.000 |
| Akurasi jawaban domain | >80% | >88% | >93% |
| Waktu respons API | <3 detik | <2 detik | <1,5 detik |

**Business Metrics:**

| Metrik | Target 60 Hari | Target 90 Hari | Target 6 Bulan |
|---|---|---|---|
| Monthly Recurring Revenue | Rp 0 (pilot gratis) | Rp 2,5 juta | Rp 25 juta |
| Paying subscribers | 0 | 5 | 50 |
| API partners | 0 | 1 | 5 |
| Churn rate | — | <10% | <7% |

**Leading Indicators:**

- Jumlah query regulasi per SPPG per minggu (indikator engagement)
- Persentase menu yang divalidasi sebelum eksekusi (indikator adopsi fitur)
- Net Promoter Score (NPS) pilot users (target: >40)

---

## 7. Ruang Lingkup Produk

### 7.1 In Scope (MVP — 60 Hari Pertama)

- Knowledge base regulasi MBG berbasis RAG (SK 244, Perpres 83, standar gizi Kemenkes, regulasi BPOM)
- AI Chatbot untuk tanya-jawab regulasi dan panduan operasional
- Validator menu gizi (input menu → output analisis nilai gizi vs standar)
- Compliance checker SK 244/2025 (cek rencana pengadaan vs persyaratan regulasi)
- Profil UMKM/supplier dan fitur basic matching dengan SPPG
- Dashboard SPPG sederhana (riwayat query, status menu, supplier aktif)
- REST API publik dengan endpoint inti (3–5 endpoint)
- Landing page dengan positioning messaging

### 7.2 Out of Scope (MVP)

- Sistem pembayaran terintegrasi antar SPPG dan UMKM
- Mobile app native (iOS/Android) — cukup progressive web app (PWA)
- Integrasi langsung dengan sistem pemerintah (SIMBGN, SIMDA, dll.)
- Fitur pelaporan otomatis ke BGN/Kemenkes
- Modul manajemen distribusi dan logistik
- Machine learning kustom / fine-tuning model sendiri
- Dashboard Dinas/pemerintah (dijadwalkan post-MVP)

### 7.3 Future Scope (Post-MVP, 3–12 Bulan)

- Mobile app (Flutter) untuk operator SPPG di lapangan
- Integrasi e-procurement pemerintah (LPSE/SIMBGN)
- White-label dashboard untuk Dinas Kesehatan kabupaten/kota
- Fitur alert otomatis untuk pembaruan regulasi
- Analitik agregat untuk BGN dan pemerintah pusat
- Fine-tuning model berbasis data feedback dari pengguna nyata

---

## 8. Fitur & Persyaratan Fungsional

### 8.1 Modul 1: MBG Regulatory Assistant (AI Chatbot)

**Deskripsi**: Antarmuka percakapan yang memungkinkan pengguna mengajukan pertanyaan dalam bahasa Indonesia (termasuk bahasa tidak formal) mengenai regulasi, prosedur, dan panduan operasional MBG.

**User Stories:**
- Sebagai koordinator SPPG, saya ingin bertanya "apakah saya wajib menggunakan supplier dari kecamatan yang sama?" dan mendapatkan jawaban akurat berbasis SK 244 dalam bahasa yang mudah dipahami.
- Sebagai UMKM, saya ingin bertanya "apa saja dokumen yang dibutuhkan untuk mendaftar jadi supplier MBG?" dan mendapatkan checklist yang actionable.
- Sebagai pengguna umum, saya ingin tahu "siapa yang berhak mendapatkan program MBG?" dan mendapatkan penjelasan yang jelas.

**Persyaratan Fungsional:**
- FR-1.1: Sistem wajib menjawab pertanyaan dalam Bahasa Indonesia (dan memahami input tidak formal/bahasa sehari-hari).
- FR-1.2: Setiap jawaban wajib menyertakan referensi ke sumber regulasi yang relevan (nomor pasal, nama regulasi).
- FR-1.3: Sistem wajib mengenali ketika pertanyaan berada di luar domain MBG dan merespons dengan tepat.
- FR-1.4: Sistem wajib mempertahankan konteks percakapan dalam satu sesi (minimal 10 giliran).
- FR-1.5: Waktu respons tidak boleh melebihi 5 detik untuk 95% query.
- FR-1.6: Sistem wajib menampilkan indikator "sedang memproses" saat mengambil jawaban.

**Acceptance Criteria:**
- Chatbot menjawab benar untuk 85%+ pertanyaan dari set pengujian 50 soal domain MBG.
- Jawaban tidak pernah berisi informasi yang bertentangan dengan regulasi yang tercatat.
- Pengguna dapat memulai percakapan baru tanpa me-refresh halaman.

---

### 8.2 Modul 2: Nutrition Menu Validator

**Deskripsi**: Alat validasi menu yang memungkinkan SPPG menginput rencana menu dan mendapatkan analisis otomatis apakah menu tersebut memenuhi standar nilai gizi yang ditetapkan Kemenkes untuk program MBG.

**User Stories:**
- Sebagai koordinator SPPG, saya ingin menginput menu "nasi, ayam goreng, tempe orek, sayur bayam, buah pisang" dan mengetahui apakah menu tersebut memenuhi kebutuhan kalori, protein, dan mikronutrien standar MBG.
- Sebagai koordinator SPPG, saya ingin mendapatkan saran penggantian bahan jika menu saya kekurangan nilai gizi tertentu.

**Persyaratan Fungsional:**
- FR-2.1: Sistem menerima input menu dalam format teks bebas (tidak perlu format terstruktur).
- FR-2.2: Sistem menghitung estimasi nilai gizi (kalori, protein, lemak, karbohidrat, minimal) per porsi berdasarkan database pangan Indonesia (TKPI — Tabel Komposisi Pangan Indonesia).
- FR-2.3: Sistem membandingkan nilai gizi yang dihitung dengan standar MBG yang berlaku (berdasarkan kelompok penerima: anak sekolah / balita / ibu hamil).
- FR-2.4: Sistem memberikan output berupa: (a) status compliance (Memenuhi / Kurang / Tidak Memenuhi), (b) rincian nilai gizi per komponen, (c) rekomendasi substitusi jika diperlukan.
- FR-2.5: Pengguna dapat memilih kategori penerima manfaat (anak SD, anak SMP, balita, ibu hamil/menyusui) sebelum validasi.
- FR-2.6: Hasil validasi dapat diunduh dalam format PDF atau disalin sebagai teks.

**Acceptance Criteria:**
- Validator berhasil menganalisis 90%+ input menu dalam bahasa Indonesia tanpa error.
- Hasil kalkulasi gizi memiliki margin error tidak lebih dari 10% dibandingkan kalkulasi manual menggunakan TKPI.
- Output mencantumkan standar referensi yang digunakan secara eksplisit.

---

### 8.3 Modul 3: SK 244 Compliance Checker

**Deskripsi**: Alat cek kepatuhan yang membantu SPPG memvalidasi rencana pengadaan supplier/bahan pangan terhadap persyaratan regulasi SK 244/2025.

**User Stories:**
- Sebagai koordinator SPPG, saya ingin menginput nama dan lokasi supplier yang akan saya gunakan, dan mengetahui apakah pilihan tersebut comply dengan persyaratan hyperlocal sourcing SK 244.
- Sebagai koordinator SPPG, saya ingin mengetahui dokumen apa saja yang harus saya kumpulkan dari supplier agar proses audit berjalan lancar.

**Persyaratan Fungsional:**
- FR-3.1: Sistem memandu pengguna melalui checklist persyaratan SK 244 secara langkah demi langkah.
- FR-3.2: Sistem memberikan penjelasan plain-language untuk setiap persyaratan.
- FR-3.3: Sistem menghasilkan laporan compliance sederhana yang dapat digunakan sebagai dokumentasi internal.
- FR-3.4: Sistem menampilkan peringatan jika ada persyaratan yang belum terpenuhi, beserta panduan tindak lanjut.

**Acceptance Criteria:**
- Checklist mencakup seluruh persyaratan material SK 244/2025 yang berlaku.
- Output laporan dapat diunduh dan memuat tanggal validasi serta versi regulasi yang digunakan.

---

### 8.4 Modul 4: UMKM Supplier Directory & Matching

**Deskripsi**: Direktori supplier UMKM yang dapat dicari oleh SPPG, dengan mekanisme pendaftaran mandiri oleh UMKM dan rekomendasi matching berbasis lokasi dan kapasitas.

**User Stories:**
- Sebagai SPPG, saya ingin menemukan supplier sayuran segar yang berlokasi dalam radius 10 km dari dapur saya.
- Sebagai UMKM katering, saya ingin membuat profil usaha saya agar bisa ditemukan oleh SPPG yang membutuhkan.

**Persyaratan Fungsional:**
- FR-4.1: UMKM dapat mendaftarkan profil meliputi: nama usaha, jenis produk, kapasitas produksi harian, lokasi, kontak, dan dokumen legalitas.
- FR-4.2: SPPG dapat mencari supplier berdasarkan filter: jenis produk, radius lokasi, kapasitas minimum, dan status verifikasi.
- FR-4.3: Sistem memberikan rekomendasi supplier berdasarkan relevansi query dan kedekatan lokasi.
- FR-4.4: Sistem menampilkan indikator kelengkapan profil UMKM untuk membantu SPPG menilai kredibilitas.
- FR-4.5: SPPG dapat menyimpan daftar supplier favorit.

**Acceptance Criteria:**
- Fitur pencarian menampilkan hasil dalam <3 detik untuk database hingga 1.000 supplier.
- Profil UMKM dapat dibuat dalam <5 menit oleh pengguna yang belum pernah menggunakan platform.

---

### 8.5 Modul 5: REST API (MBGBrain API)

**Deskripsi**: Antarmuka pemrograman yang memungkinkan developer dan vendor pihak ketiga mengintegrasikan intelligence MBG ke dalam sistem mereka sendiri.

**Endpoints Inti (MVP):**

| Endpoint | Method | Deskripsi |
|---|---|---|
| `/api/v1/chat` | POST | Query AI chatbot regulasi MBG |
| `/api/v1/validate-menu` | POST | Validasi nilai gizi menu vs standar MBG |
| `/api/v1/compliance-check` | POST | Cek kepatuhan terhadap SK 244 |
| `/api/v1/suppliers/search` | GET | Cari supplier UMKM berdasarkan parameter |
| `/api/v1/regulations/latest` | GET | Dapatkan daftar regulasi MBG terbaru |

**Persyaratan Fungsional:**
- FR-5.1: Seluruh endpoint wajib menggunakan autentikasi Bearer Token (API Key).
- FR-5.2: Sistem wajib menerapkan rate limiting per API key (default: 100 req/menit).
- FR-5.3: Seluruh respons dalam format JSON dengan struktur yang konsisten.
- FR-5.4: Sistem menyediakan dokumentasi API interaktif (Swagger/OpenAPI 3.0).
- FR-5.5: Setiap respons API menyertakan header `X-Regulation-Version` yang menunjukkan versi regulasi yang digunakan.
- FR-5.6: Sistem menyediakan webhook untuk notifikasi pembaruan regulasi.

---

## 9. Persyaratan Non-Fungsional

### 9.1 Performa

| Requirement | Target |
|---|---|
| Waktu respons AI query (P95) | < 5 detik |
| Waktu respons API endpoint (P95) | < 2 detik |
| Uptime | > 99,5% per bulan |
| Throughput | Minimal 50 concurrent users (MVP) |

### 9.2 Keamanan

- Seluruh komunikasi wajib menggunakan HTTPS/TLS 1.2+.
- API Key di-hash sebelum disimpan di database; tidak pernah disimpan dalam plaintext.
- Data pengguna disimpan di server Indonesia (Supabase region Asia Tenggara) untuk kepatuhan data sovereignty.
- Input pengguna wajib di-sanitasi sebelum diproses (mencegah prompt injection).
- Tidak ada data personal identifiable (PII) yang diteruskan ke LLM provider tanpa consent eksplisit.

### 9.3 Skalabilitas

- Arsitektur stateless pada layer API — mendukung horizontal scaling.
- Knowledge base menggunakan vector database yang dapat di-shard.
- Caching pada query yang sering diulang (regulasi statis) untuk mengurangi biaya LLM API.

### 9.4 Maintainability

- Regulasi dapat diperbarui dalam knowledge base tanpa deploy ulang aplikasi (melalui admin panel atau script CLI).
- Seluruh kode memiliki test coverage minimal 70% untuk modul inti.
- Dokumentasi teknis dan API selalu disinkronkan dengan kode (code-as-documentation).

### 9.5 Aksesibilitas & Usability

- Antarmuka web responsif — dapat digunakan di smartphone (screen width 360px+).
- Mendukung input teks Bahasa Indonesia termasuk singkatan dan bahasa tidak formal.
- Tidak memerlukan instalasi aplikasi — berbasis web/PWA.
- Onboarding mandiri < 10 menit untuk pengguna baru tanpa panduan eksternal.

---

## 10. Arsitektur Teknis

### 10.1 Stack Teknologi

| Layer | Teknologi | Justifikasi |
|---|---|---|
| **Frontend** | Next.js 14 (App Router) + Tailwind CSS | SSR untuk SEO, familiar bagi developer |
| **Backend API** | FastAPI (Python) | Performa tinggi, async-native, cocok untuk AI workloads |
| **Database Utama** | PostgreSQL via Supabase | Relational + Row Level Security, managed |
| **Vector Database** | Supabase pgvector | Terpadu dengan PostgreSQL, tidak perlu infra terpisah (MVP) |
| **LLM Provider** | Anthropic Claude API (claude-sonnet) | Performa tinggi, konteks panjang, biaya terkontrol |
| **Embedding Model** | OpenAI text-embedding-3-small | Biaya rendah, kualitas cukup untuk domain terbatas |
| **Autentikasi** | Supabase Auth | Managed, mendukung magic link & OAuth |
| **File Storage** | Supabase Storage | Untuk dokumen regulasi dan laporan PDF |
| **Deployment** | Railway / Fly.io (Backend) + Vercel (Frontend) | Zero-ops, mudah di-manage solo |
| **Monitoring** | Sentry (error) + Uptime Robot (availability) | Gratis/murah untuk skala awal |

### 10.2 Diagram Alur Sistem (High-Level)

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
    │                    (System prompt + retrieved context + user query)
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

### 10.3 RAG Pipeline Detail

1. **Ingestion Phase** (offline, dilakukan saat setup awal dan update):
   - Regulasi PDF/dokumen → text extraction (pdfplumber/pymupdf)
   - Text chunking dengan sliding window (chunk size: 512 token, overlap: 64 token)
   - Embedding generation (OpenAI text-embedding-3-small)
   - Storage ke Supabase pgvector dengan metadata (source, versi regulasi, tanggal efektif)

2. **Retrieval Phase** (runtime, setiap query):
   - User query → embedding
   - Cosine similarity search pada pgvector (top-k: 5 chunks)
   - Re-ranking berdasarkan relevansi dan recency regulasi

3. **Generation Phase** (runtime):
   - Prompt construction: system prompt (instruksi peran + constraint) + retrieved context + user query
   - Claude API call dengan temperature 0.2 (untuk konsistensi faktual)
   - Response dengan citation ke sumber regulasi

---

## 11. Arsitektur Data & Knowledge Base

### 11.1 Sumber Data Knowledge Base

| Kategori | Sumber | Format | Update Frequency |
|---|---|---|---|
| Regulasi utama MBG | Situs resmi BGN, JDIH Kemenkes, JDIH Kemensetneg | PDF, HTML | Per pembaruan regulasi |
| Standar gizi Kemenkes | PMK No. 28/2019, TKPI 2017 (edisi terbaru) | PDF, Excel | Tahunan |
| Regulasi BPOM (keamanan pangan) | BPOM.go.id | PDF | Per pembaruan |
| Juknis SPPG dari BGN | Distribusi resmi BGN | PDF | Per pembaruan |
| Data pangan lokal Indonesia | TKPI Kemenkes, Panganku.org | Excel, JSON | Tahunan |

### 11.2 Schema Database Utama

```sql
-- Users & Organizations
users (id, email, role: ENUM[sppg_admin, umkm, dinas, public, api_user], created_at)
organizations (id, name, type: ENUM[sppg, umkm, dinas], province, city, district, verified_at)
user_organizations (user_id, org_id, role)

-- Knowledge Base
regulation_documents (id, title, type, effective_date, version, source_url, full_text, created_at)
knowledge_chunks (id, doc_id, chunk_text, chunk_index, embedding VECTOR(1536), metadata JSONB)

-- Supplier Directory
suppliers (id, org_id, product_categories TEXT[], daily_capacity_servings, location GEOGRAPHY, is_verified, profile_completeness_pct)
supplier_documents (id, supplier_id, doc_type, file_url, verified_at)

-- SPPG Operations
menu_validations (id, sppg_org_id, menu_input TEXT, analysis_result JSONB, compliance_status, created_at)
compliance_checks (id, sppg_org_id, check_type, inputs JSONB, result JSONB, created_at)

-- API Management
api_keys (id, user_id, key_hash, name, rate_limit_per_min, total_calls, last_used_at, is_active)

-- Audit & Analytics
query_logs (id, user_id, module, query_text, response_time_ms, created_at)
```

---

## 12. Model Monetisasi & Offer Architecture

### 12.1 Tier Produk

**Tier 1 — MBGBrain Lite (Freemium)**
- Target: Masyarakat umum, SPPG yang belum yakin
- Harga: Gratis
- Batasan: 50 query AI/bulan, akses chatbot regulasi saja, tidak ada validator menu
- Tujuan strategis: Akuisisi pengguna, SEO authority, word-of-mouth

**Tier 2 — MBGBrain Pro SPPG (Core Product)**
- Target: Koordinator dan admin SPPG aktif
- Harga: Rp 299.000/bulan (Early Bird) → Rp 499.000/bulan (reguler)
- Fitur: Chatbot regulasi unlimited + validator menu + compliance checker SK 244 + supplier directory + ekspor laporan PDF
- Tujuan strategis: Primary revenue stream, membangun loyalitas

**Tier 3 — MBGBrain API (Developer & Vendor)**
- Target: Developer, startup, perusahaan katering yang punya sistem sendiri
- Harga: Rp 50/query (pay-as-you-go) atau paket bulanan Rp 1.500.000 (30.000 query)
- Fitur: Full API access, webhook update regulasi, SLA 99,5%
- Tujuan strategis: Revenue diversifikasi, distribusi tidak langsung

**Tier 4 — MBGBrain Enterprise (Future)**
- Target: Dinas Kesehatan kabupaten/kota, konsultan pemerintah
- Harga: Negosiasi (Rp 15–50 juta/tahun per instansi)
- Fitur: White-label dashboard, SSO, dedicated support, laporan agregat wilayah

### 12.2 Psychological Pricing Rationale

- Rp 299.000 diposisikan sebagai "tidak sampai Rp 300 ribu" — threshold psikologis penting untuk segmen pemerintah daerah.
- Early Bird bukan sekadar diskon — ini adalah sinyal bahwa harga akan naik, menciptakan urgensi konversi.
- API pay-per-call memudahkan eksperimen tanpa commitment awal — barrier to entry rendah, barrier to exit tinggi (setelah terintegrasi).

---

## 13. Competitive Positioning

### 13.1 Lanskap Kompetitif

| Kompetitor Potensial | Kelemahan vs MBGBrain |
|---|---|
| ChatGPT / Claude umum (tanpa konteks MBG) | Tidak punya knowledge corpus MBG, jawaban generik, tidak ada citation regulasi |
| Chatbot kustom berbasis ChatGPT wrapper | Mudah dibuat tapi tanpa data domain, mudah ditiru, tidak ada moat |
| Sistem informasi pemerintah (SIMBGN, dll.) | Bukan tools berbasis AI, tidak interaktif, sulit diakses dan digunakan |
| Konsultan manual regulasi MBG | Mahal, tidak scalable, tidak tersedia 24/7 |

### 13.2 Keunggulan Defensif MBGBrain

1. **First-mover advantage** pada AI khusus MBG — siapapun yang masuk belakangan harus membangun corpus dari nol.
2. **Data flywheel** — semakin banyak SPPG yang menggunakan, semakin banyak data feedback yang memperbaiki akurasi sistem.
3. **Regulatory authority** — jika MBGBrain menjadi rujukan pertama untuk pertanyaan MBG, ini menciptakan switching cost yang tinggi secara psikologis.
4. **Network effect** pada supplier directory — nilai direktori meningkat seiring bertambahnya supplier dan SPPG terdaftar.

---

## 14. Roadmap & Milestones

### Fase 1: Fondasi (Hari 1–15)

| Deliverable | Detail | Status |
|---|---|---|
| MBG Knowledge Corpus v1 | Scraping + indexing 10+ regulasi utama, embedding ke pgvector | Not started |
| RAG Pipeline MVP | FastAPI + pgvector + Claude API, dapat menjawab 50 test query | Not started |
| Basic auth system | Supabase Auth, user registration, role assignment | Not started |
| Akurasi baseline | Uji 50 soal domain, dokumentasi hasil | Not started |

### Fase 2: MVP Build (Hari 16–35)

| Deliverable | Detail | Status |
|---|---|---|
| Web app v0.1 | Next.js + 3 modul inti (chatbot, validator menu, compliance checker) | Not started |
| Supplier directory basic | Pendaftaran UMKM + pencarian sederhana | Not started |
| REST API v1 | 5 endpoint inti + dokumentasi Swagger | Not started |
| Landing page | Positioning messaging + CTA waitlist/trial | Not started |
| 2 SPPG pilot | Onboarding SPPG pertama di Malang/Jatim | Not started |

### Fase 3: Traction & Revenue (Hari 36–60)

| Deliverable | Detail | Status |
|---|---|---|
| 5 SPPG aktif | Minimal 10 query/minggu per SPPG | Not started |
| Case study #1 | Dokumentasi hasil nyata pilot pertama | Not started |
| Konversi ke paid | Early Bird pricing aktif, target 3 paying subscribers | Not started |
| Submission hackathon | Submit ke kompetisi GovTech/MBG terkait | Not started |
| Knowledge Corpus v2 | Perbarui berdasarkan pertanyaan pengguna nyata | Not started |

---

## 15. Asumsi & Ketergantungan

### 15.1 Asumsi

- Regulasi MBG (SK 244/2025 dan turunannya) tersedia secara publik dan dapat diakses untuk keperluan indexing.
- SPPG pilot bersedia dicapai melalui jaringan komunitas atau cold outreach langsung.
- Claude API tetap tersedia dengan SLA yang memadai untuk skala MVP.
- Biaya operasional LLM API dapat ditutupi oleh pendapatan dari tier Pro dan API.
- Tidak ada perubahan regulasi MBG yang bersifat fundamental dalam 60 hari pertama pengembangan.

### 15.2 Ketergantungan

| Dependensi | Risiko Jika Tidak Terpenuhi | Mitigasi |
|---|---|---|
| Anthropic Claude API | Biaya tak terduga / downtime | Maintain fallback ke OpenAI GPT-4o |
| Ketersediaan regulasi publik | Knowledge base tidak lengkap | Tambah sumber alternatif (media, asosiasi MBG) |
| Supabase (database + auth) | Vendor lock-in | Arsitektur dapat dipindah ke self-hosted PostgreSQL |
| Akses SPPG pilot | Tidak ada feedback nyata | Gunakan simulasi persona dari wawancara 5 orang praktisi |

---

## 16. Risiko & Mitigasi

| Risiko | Probabilitas | Dampak | Mitigasi |
|---|---|---|---|
| Akurasi AI rendah untuk pertanyaan kompleks | Sedang | Tinggi | Hybrid: AI + fallback ke teks regulasi langsung; disclaimer akurasi |
| Regulasi MBG berubah mendadak | Sedang | Tinggi | Sistem update regulasi via pipeline CLI, bukan hardcode |
| Tidak ada SPPG yang mau jadi pilot | Rendah | Sangat Tinggi | Mulai dari koneksi personal / jaringan Pramuka / komunitas akademik |
| Kompetitor lebih besar masuk lebih cepat | Rendah | Sedang | Fokus pada data moat dan jaringan — keunggulan yang tidak bisa dikopi cepat |
| Biaya LLM API melebihi estimasi | Sedang | Sedang | Implementasi caching agresif untuk query berulang; monitor cost per query |
| Pengguna tidak percaya AI untuk keputusan regulasi | Sedang | Tinggi | Selalu tampilkan sumber regulasi asli; posisikan sebagai "asisten", bukan "pengganti ahli" |

---

## 17. Kriteria Penerimaan (Definition of Done)

Sebuah fitur dianggap selesai (done) ketika:

1. Seluruh acceptance criteria yang didefinisikan dalam Modul terkait terpenuhi.
2. Unit test untuk logika inti telah ditulis dan lulus (coverage > 70% per modul).
3. Endpoint API yang relevan telah didokumentasikan di Swagger.
4. Fitur telah diuji oleh minimal 1 orang pengguna eksternal (bukan developer) dan feedback kritis telah diaddress.
5. Tidak ada regresi pada fitur yang sudah berjalan.
6. Knowledge base yang relevan telah diperbarui jika fitur berkaitan dengan regulasi.

---

## 18. Glosarium

| Istilah | Definisi |
|---|---|
| **MBG** | Makan Bergizi Gratis — program pemerintah penyediaan makanan bergizi gratis bagi penerima manfaat yang ditentukan. |
| **SPPG** | Satuan Pelayanan Pemenuhan Gizi — unit operasional pelaksana program MBG di tingkat kecamatan/kabupaten. |
| **BGN** | Badan Gizi Nasional — lembaga pemerintah yang mengkoordinasikan program MBG secara nasional. |
| **SK 244** | Surat Keputusan Kepala BGN No. 244 Tahun 2025 — regulasi yang mengatur matching SPPG-UMKM. |
| **RAG** | Retrieval-Augmented Generation — teknik AI yang menggabungkan pencarian dokumen dengan generasi teks untuk menghasilkan jawaban yang akurat dan berbasis sumber. |
| **LLM** | Large Language Model — model AI generatif berukuran besar (contoh: GPT-4, Claude). |
| **pgvector** | Ekstensi PostgreSQL untuk menyimpan dan mencari vector embedding secara efisien. |
| **TKPI** | Tabel Komposisi Pangan Indonesia — database nilai gizi pangan yang diterbitkan oleh Kemenkes RI. |
| **Moat** | Keunggulan kompetitif yang sulit ditiru oleh kompetitor dalam jangka pendek. |
| **Hyperlocal sourcing** | Kewajiban pengadaan bahan pangan dari supplier yang berlokasi di wilayah terdekat dengan SPPG. |
| **Fine-tuning** | Proses melatih ulang model AI yang sudah ada menggunakan data domain spesifik. |

---

*Dokumen ini akan diperbarui seiring perkembangan produk. Setiap perubahan material pada scope atau persyaratan wajib didokumentasikan dengan tanggal revisi dan justifikasi perubahan.*

*Versi 1.0.0 — 15 Mei 2026*
