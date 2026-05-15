import { ChefHat, MessageSquare, ShieldCheck, Store, type LucideIcon } from 'lucide-react';

export interface LandingModule {
  id: string;
  icon: LucideIcon;
  title: string;
  tagline: string;
  shortDescription: string;
  href: string;
  highlights: string[];
  details: string[];
  useCases: string[];
  regulation?: string;
}

export const LANDING_MODULES: LandingModule[] = [
  {
    id: 'chat',
    icon: MessageSquare,
    title: 'Regulasi Assistant',
    tagline: 'Jawaban regulasi MBG dalam hitungan detik',
    shortDescription:
      'Asisten AI dengan citation SK 244, Perpres 83, dan standar Kemenkes — bahasa Indonesia sehari-hari.',
    href: '/chat',
    highlights: ['Citation regulasi', 'Bahasa Indonesia natural', 'Mode demo & RAG'],
    details: [
      'Tanya jawab tentang SK 244/2025, hyperlocal sourcing, persyaratan supplier, dan prosedur SPPG.',
      'Setiap jawaban menyertakan referensi pasal dan kutipan regulasi yang dapat diperluas.',
      'Mendukung input informal — sistem memahami konteks percakapan multi-giliran.',
    ],
    useCases: [
      'Koordinator SPPG memverifikasi kewajiban pengadaan lokal',
      'UMKM memahami dokumen pendaftaran supplier resmi',
      'Persiapan audit BPKP dengan panduan terstruktur',
    ],
    regulation: 'SK 244/2025 · Perpres 83/2024',
  },
  {
    id: 'validator',
    icon: ChefHat,
    title: 'Validator Menu Gizi',
    tagline: 'Validasi menu sebelum dieksekusi',
    shortDescription:
      'Analisis nilai gizi otomatis berbasis TKPI untuk SD, SMP, balita, dan ibu hamil/menyusui.',
    href: '/validator',
    highlights: ['Parse menu bahasa bebas', 'Progress bar per nutrisi', 'Rekomendasi substitusi'],
    details: [
      'Input menu seperti: nasi 200g, ayam goreng 75g, tempe, sayur bayam, pisang.',
      'Perbandingan otomatis dengan standar gizi MBG per kelompok penerima manfaat.',
      'Skor kepatuhan 0–100 dengan status Memenuhi / Kurang / Tidak Memenuhi.',
    ],
    useCases: [
      'Perencanaan menu mingguan SPPG',
      'Review gizi sebelum distribusi',
      'Dokumentasi internal untuk dinas kesehatan',
    ],
    regulation: 'Standar Gizi Kemenkes · Pedoman BGN 2025',
  },
  {
    id: 'compliance',
    icon: ShieldCheck,
    title: 'Cek Kepatuhan SK 244',
    tagline: 'Checklist audit-ready untuk SPPG',
    shortDescription:
      'Panduan langkah demi langkah hyperlocal sourcing, legalitas supplier, dan dokumen audit.',
    href: '/compliance',
    highlights: ['Checklist interaktif', 'Progress compliance', 'Laporan PDF (Fase 3)'],
    details: [
      'Validasi nama & lokasi supplier terhadap persyaratan wilayah setempat.',
      'Enam kategori persyaratan material SK 244 dengan penjelasan plain-language.',
      'Generate laporan status dengan tanggal dan versi regulasi.',
    ],
    useCases: [
      'Persiapan audit BPKP / inspeksi internal',
      'Onboarding supplier UMKM baru',
      'Dokumentasi kepatuhan bulanan SPPG',
    ],
    regulation: 'SK Kepala BGN No. 244 Tahun 2025',
  },
  {
    id: 'suppliers',
    icon: Store,
    title: 'Direktori UMKM',
    tagline: 'Matching supplier hyperlocal',
    shortDescription:
      'Cari UMKM katering & supplier pangan berdasarkan radius, kapasitas, dan verifikasi profil.',
    href: '/suppliers',
    highlights: ['Filter radius km', 'Status verifikasi', 'Kelengkapan profil %'],
    details: [
      'Pencarian berdasarkan jenis produk, jarak dari dapur SPPG, dan kapasitas porsi/hari.',
      'Indikator kelengkapan profil membantu menilai kredibilitas supplier.',
      'Integrasi geospatial penuh setelah Fase 2 (PostGIS).',
    ],
    useCases: [
      'SPPG menemukan supplier sayur dalam radius 10 km',
      'UMKM mendaftarkan kapasitas produksi harian',
      'Koordinasi hyperlocal sourcing SK 244',
    ],
    regulation: 'SK 244/2025 — Hyperlocal Sourcing',
  },
];

export const TYPING_PHRASES = [
  'validasi menu gizi untuk siswa SD…',
  'cek hyperlocal sourcing SK 244…',
  'cari supplier UMKM terdekat…',
  'persiapan audit BPKP…',
];
