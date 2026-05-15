/** Demo data & responses when API backend is unavailable (Fase 1 UI) */

export const DEMO_CHAT_RESPONSE = `Berdasarkan **SK Kepala BGN No. 244 Tahun 2025**, SPPG diwajibkan memprioritaskan pengadaan bahan pangan dari UMKM/supplier yang berlokasi di wilayah yang sama atau terdekat (hyperlocal sourcing).

**Poin utama:**
- Supplier sebaiknya berasal dari kecamatan/kabupaten yang sama dengan lokasi SPPG
- Dokumen legalitas (NIB, sertifikat halal/BPOM jika diperlukan) harus lengkap
- Kapasitas produksi harus memadai untuk kebutuhan porsi harian SPPG

[Sumber: SK 244/2025 BGN, ketentuan hyperlocal sourcing]`;

export const DEMO_CITATIONS = [
  {
    regulation: 'SK 244/2025',
    article: 'Pasal tentang Hyperlocal Sourcing',
    excerpt:
      'SPPG wajib memprioritaskan pengadaan bahan pangan dari pelaku usaha yang berlokasi di wilayah setempat...',
  },
];

export const DEMO_SUPPLIERS = [
  {
    id: '1',
    name: 'Katering Sejahtera Malang',
    category: 'Sayuran & lauk',
    distanceKm: 3.2,
    capacity: 800,
    verified: true,
    completeness: 92,
  },
  {
    id: '2',
    name: 'UMKM Tempe Jaya',
    category: 'Protein nabati',
    distanceKm: 5.1,
    capacity: 500,
    verified: true,
    completeness: 85,
  },
  {
    id: '3',
    name: 'Dapur Bersama Ngawi',
    category: 'Katering lengkap',
    distanceKm: 8.4,
    capacity: 1200,
    verified: false,
    completeness: 68,
  },
];

export const DEMO_VALIDATION_RESULT = {
  status: 'kurang' as const,
  score: 78,
  nutrients: [
    { name: 'Energi kkal', value: 520, unit: 'kkal', standard: 600, percentage: 86.7, status: 'kurang' as const },
    { name: 'Protein g', value: 18.5, unit: 'g', standard: 15, percentage: 123.3, status: 'memenuhi' as const },
    { name: 'Lemak g', value: 14.2, unit: 'g', standard: 10, percentage: 142, status: 'memenuhi' as const },
    { name: 'Karbohidrat g', value: 72, unit: 'g', standard: 60, percentage: 120, status: 'memenuhi' as const },
  ],
  suggestions: [
    'Tambah sumber energi kkal — masih 13% di bawah standar untuk siswa SD',
    'Pertimbangkan tambahan porsi nasi 30–40g atau snack buah untuk mencapai target energi',
  ],
  regulation: 'Standar Gizi MBG — Kemenkes RI & Pedoman BGN 2025',
};
