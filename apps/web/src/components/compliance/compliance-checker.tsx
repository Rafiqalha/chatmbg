'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ShieldCheck,
  CheckCircle2,
  Circle,
  AlertTriangle,
  Download,
  ChevronRight,
} from 'lucide-react';
import toast from 'react-hot-toast';
import { cn } from '@/lib/utils';
import { apiFetch } from '@/lib/api';

interface ChecklistItem {
  id: string;
  title: string;
  description: string;
  regulation: string;
}

const SK244_CHECKLIST: ChecklistItem[] = [
  {
    id: 'hyperlocal',
    title: 'Hyperlocal sourcing',
    description:
      'Supplier berada di wilayah kecamatan/kabupaten yang sama atau terdekat dengan lokasi SPPG.',
    regulation: 'SK 244/2025',
  },
  {
    id: 'nib',
    title: 'NIB & legalitas usaha',
    description: 'Supplier memiliki Nomor Induk Berusaha (NIB) yang masih berlaku.',
    regulation: 'SK 244/2025',
  },
  {
    id: 'kapasitas',
    title: 'Kapasitas produksi',
    description: 'Kapasitas harian supplier memadai untuk kebutuhan porsi SPPG.',
    regulation: 'SK 244/2025',
  },
  {
    id: 'halal',
    title: 'Sertifikat halal / BPOM',
    description: 'Dokumen keamanan pangan sesuai jenis produk yang disuplai.',
    regulation: 'Regulasi BPOM',
  },
  {
    id: 'kontrak',
    title: 'Perjanjian kerja sama',
    description: 'Dokumen perjanjian atau surat kesepakatan dengan supplier tercatat.',
    regulation: 'Pedoman BGN',
  },
  {
    id: 'laporan',
    title: 'Dokumentasi pelaporan',
    description: 'Bukti transaksi dan laporan pengadaan siap untuk audit.',
    regulation: 'SK 244/2025',
  },
];

export function ComplianceChecker() {
  const [checked, setChecked] = useState<Record<string, boolean>>({});
  const [supplierName, setSupplierName] = useState('');
  const [supplierLocation, setSupplierLocation] = useState('');
  const [showReport, setShowReport] = useState(false);

  const completed = Object.values(checked).filter(Boolean).length;
  const total = SK244_CHECKLIST.length;
  const pct = Math.round((completed / total) * 100);

  const overallStatus =
    pct >= 100 ? 'memenuhi' : pct >= 70 ? 'kurang' : 'tidak_memenuhi';

  const statusLabel = {
    memenuhi: 'Siap Audit',
    kurang: 'Perlu Perbaikan',
    tidak_memenuhi: 'Belum Memenuhi',
  }[overallStatus];

  const toggle = (id: string) => {
    setChecked((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  const generateReport = async () => {
    const inputs: Record<string, unknown> = {
      has_nib: checked.nib ?? false,
      has_halal_cert: checked.halal ?? false,
      halal_na: !checked.halal,
      has_contract: checked.kontrak ?? false,
      bpom_compliant: checked.halal ?? false,
      supplier_same_district: checked.hyperlocal ?? false,
      daily_capacity: checked.kapasitas ? 500 : 0,
      required_servings: 200,
    };
    try {
      const res = await apiFetch('/api/v1/compliance-check', {
        method: 'POST',
        body: JSON.stringify({ check_type: 'sk244_supplier', inputs }),
      });
      if (res.ok) await res.json();
    } catch {
      /* laporan lokal tetap ditampilkan */
    }
    setShowReport(true);
    toast.success('Laporan compliance dibuat');
  };

  return (
    <div className="mx-auto max-w-2xl space-y-6 overflow-y-auto p-4 sm:p-6">
      <div>
        <h1 className="font-display flex items-center gap-2.5 text-2xl font-semibold text-neutral-900 dark:text-neutral-100">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary-500">
            <ShieldCheck className="h-5 w-5 text-white" />
          </span>
          Cek Kepatuhan SK 244
        </h1>
        <p className="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
          Checklist interaktif persyaratan SK Kepala BGN No. 244 Tahun 2025 untuk pengadaan
          supplier MBG.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <label className="mb-2 block text-sm font-medium text-neutral-700 dark:text-neutral-300">
            Nama Supplier
          </label>
          <input
            type="text"
            value={supplierName}
            onChange={(e) => setSupplierName(e.target.value)}
            placeholder="Contoh: Katering Sejahtera"
            className="w-full rounded-xl border border-neutral-200 bg-white px-4 py-2.5 text-sm focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-100"
          />
        </div>
        <div>
          <label className="mb-2 block text-sm font-medium text-neutral-700 dark:text-neutral-300">
            Lokasi Supplier
          </label>
          <input
            type="text"
            value={supplierLocation}
            onChange={(e) => setSupplierLocation(e.target.value)}
            placeholder="Kecamatan, Kabupaten"
            className="w-full rounded-xl border border-neutral-200 bg-white px-4 py-2.5 text-sm focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-100"
          />
        </div>
      </div>

      <div className="rounded-2xl border border-neutral-200 bg-white p-4 dark:border-neutral-700 dark:bg-neutral-800/50">
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="mb-3 flex items-center justify-between"
        >
          <span className="text-sm font-medium text-neutral-700 dark:text-neutral-300">
            Progress checklist
          </span>
          <span className="text-sm font-bold text-primary-600">
            {completed}/{total} ({pct}%)
          </span>
        </motion.div>
        <div className="h-2 overflow-hidden rounded-full bg-neutral-100 dark:bg-neutral-800">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${pct}%` }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
            className={cn(
              'h-full rounded-full',
              overallStatus === 'memenuhi'
                ? 'bg-primary-500'
                : overallStatus === 'kurang'
                  ? 'bg-accent-400'
                  : 'bg-red-500'
            )}
          />
        </div>
      </div>

      <div className="space-y-2">
        {SK244_CHECKLIST.map((item, i) => {
          const isChecked = checked[item.id];
          return (
            <motion.button
              key={item.id}
              type="button"
              initial={{ opacity: 0, x: -8 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.05 }}
              onClick={() => toggle(item.id)}
              className={cn(
                'flex w-full items-start gap-3 rounded-2xl border p-4 text-left transition-all duration-150',
                isChecked
                  ? 'border-primary-300 bg-primary-50 dark:border-primary-700 dark:bg-primary-900/20'
                  : 'border-neutral-200 bg-white hover:border-neutral-300 dark:border-neutral-700 dark:bg-neutral-800 dark:hover:border-neutral-600'
              )}
            >
              {isChecked ? (
                <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary-600" />
              ) : (
                <Circle className="mt-0.5 h-5 w-5 shrink-0 text-neutral-300 dark:text-neutral-600" />
              )}
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-semibold text-neutral-900 dark:text-neutral-100">
                    {item.title}
                  </span>
                  <span className="rounded-md bg-primary-500/10 px-1.5 py-0.5 text-[10px] font-bold text-primary-700 dark:text-primary-300">
                    {item.regulation}
                  </span>
                </div>
                <p className="mt-1 text-xs leading-relaxed text-neutral-500 dark:text-neutral-400">
                  {item.description}
                </p>
              </div>
              <ChevronRight className="h-4 w-4 shrink-0 text-neutral-400" />
            </motion.button>
          );
        })}
      </div>

      <button
        type="button"
        onClick={generateReport}
        className="flex w-full items-center justify-center gap-2 rounded-2xl bg-primary-500 py-3 text-sm font-semibold text-white shadow-sm shadow-primary-500/30 transition-all hover:bg-primary-600 active:scale-[0.98]"
      >
        <ShieldCheck className="h-4 w-4" />
        Buat Laporan Compliance
      </button>

      <AnimatePresence>
        {showReport && (
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 16 }}
            className={cn(
              'rounded-2xl border p-5',
              overallStatus === 'memenuhi'
                ? 'border-primary-200 bg-primary-50 dark:border-primary-800 dark:bg-primary-900/20'
                : 'border-accent-200 bg-accent-50 dark:border-accent-800 dark:bg-accent-900/20'
            )}
          >
            <div className="flex items-start gap-3">
              {overallStatus === 'memenuhi' ? (
                <CheckCircle2 className="h-6 w-6 shrink-0 text-primary-600" />
              ) : (
                <AlertTriangle className="h-6 w-6 shrink-0 text-accent-600" />
              )}
              <div>
                <h3 className="font-semibold text-neutral-900 dark:text-neutral-100">
                  Status: {statusLabel}
                </h3>
                <p className="mt-1 text-sm text-neutral-600 dark:text-neutral-400">
                  {supplierName || 'Supplier'} — {supplierLocation || 'Lokasi belum diisi'}
                </p>
                <p className="mt-2 text-xs text-neutral-500">
                  Versi regulasi: SK 244/2025 BGN · Validasi:{' '}
                  {new Date().toLocaleDateString('id-ID')}
                </p>
                {overallStatus !== 'memenuhi' && (
                  <p className="mt-3 text-sm text-accent-700 dark:text-accent-300">
                    Lengkapi {total - completed} persyaratan yang belum terpenuhi sebelum audit.
                  </p>
                )}
              </div>
            </div>
            <button
              type="button"
              onClick={() => toast('Ekspor PDF tersedia setelah Fase 3')}
              className="mt-4 flex w-full items-center justify-center gap-2 rounded-xl border border-neutral-200 bg-white py-2.5 text-sm font-medium dark:border-neutral-700 dark:bg-neutral-800"
            >
              <Download className="h-4 w-4" /> Unduh Laporan PDF
            </button>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
