'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChefHat, CheckCircle2, XCircle, AlertTriangle, Download, RefreshCw, School, BookOpen, Baby, HeartHandshake, type LucideIcon } from 'lucide-react';
import toast from 'react-hot-toast';
import { cn } from '@/lib/utils';
import { DEMO_VALIDATION_RESULT } from '@/lib/mock/demo-data';
import { apiJson } from '@/lib/api';

type RecipientGroup = 'sd' | 'smp' | 'balita' | 'bumil';
type ComplianceStatus = 'memenuhi' | 'kurang' | 'tidak_memenuhi';

interface NutrientResult {
  name: string;
  value: number;
  unit: string;
  standard: number;
  percentage: number;
  status: ComplianceStatus;
}

interface ValidationResult {
  status: ComplianceStatus;
  score: number;
  nutrients: NutrientResult[];
  suggestions: string[];
  regulation: string;
}

const RECIPIENT_GROUPS: { value: RecipientGroup; label: string; icon: LucideIcon }[] = [
  { value: 'sd', label: 'Siswa SD', icon: School },
  { value: 'smp', label: 'Siswa SMP', icon: BookOpen },
  { value: 'balita', label: 'Balita (2–5 th)', icon: Baby },
  { value: 'bumil', label: 'Ibu Hamil/Menyusui', icon: HeartHandshake },
];

const STATUS_CONFIG = {
  memenuhi: {
    label: 'Memenuhi Standar',
    icon: CheckCircle2,
    color: 'text-primary-600',
    bg: 'bg-primary-50 dark:bg-primary-900/30',
    border: 'border-primary-200 dark:border-primary-800',
  },
  kurang: {
    label: 'Kurang',
    icon: AlertTriangle,
    color: 'text-accent-600',
    bg: 'bg-accent-50 dark:bg-accent-900/30',
    border: 'border-accent-200 dark:border-accent-800',
  },
  tidak_memenuhi: {
    label: 'Tidak Memenuhi',
    icon: XCircle,
    color: 'text-red-600',
    bg: 'bg-red-50 dark:bg-red-900/30',
    border: 'border-red-200 dark:border-red-800',
  },
};

function NutrientBar({ nutrient }: { nutrient: NutrientResult }) {
  const pct = Math.min(nutrient.percentage, 150);
  const color =
    nutrient.status === 'memenuhi'
      ? 'bg-primary-500'
      : nutrient.status === 'kurang'
        ? 'bg-accent-400'
        : 'bg-red-500';

  return (
    <div className="space-y-1.5">
      <motion.div
        initial={{ opacity: 0, y: 4 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.2 }}
        className="flex items-center justify-between text-sm"
      >
        <span className="font-medium text-neutral-700 dark:text-neutral-300">{nutrient.name}</span>
        <span className="text-xs text-neutral-500 dark:text-neutral-400">
          {nutrient.value.toFixed(1)} / {nutrient.standard} {nutrient.unit}
          <span
            className="ml-2 text-xs font-semibold"
            style={{
              color:
                nutrient.status === 'memenuhi'
                  ? '#2a9d5c'
                  : nutrient.status === 'kurang'
                    ? '#d97706'
                    : '#dc2626',
            }}
          >
            {nutrient.percentage.toFixed(0)}%
          </span>
        </span>
      </motion.div>
      <div className="h-2 overflow-hidden rounded-full bg-neutral-100 dark:bg-neutral-800">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${pct}%` }}
          transition={{ duration: 0.8, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
          className={cn('h-full rounded-full', color)}
        />
      </div>
    </div>
  );
}

export function MenuValidator() {
  const [menuInput, setMenuInput] = useState('');
  const [recipient, setRecipient] = useState<RecipientGroup>('sd');
  const [result, setResult] = useState<ValidationResult | null>(null);
  const [loading, setLoading] = useState(false);

  const validate = async () => {
    if (!menuInput.trim()) return;
    setLoading(true);
    try {
      const data = await apiJson<ValidationResult>('/api/v1/validate-menu', {
        method: 'POST',
        body: JSON.stringify({ menu: menuInput, recipient_group: recipient }),
      });
      setResult(data);
    } catch {
      await new Promise((r) => setTimeout(r, 800));
      setResult(DEMO_VALIDATION_RESULT);
      toast('Mode demo — hasil contoh analisis gizi', { icon: 'ℹ️' });
    } finally {
      setLoading(false);
    }
  };

  const statusCfg = result ? STATUS_CONFIG[result.status] : null;

  return (
    <div className="mx-auto max-w-2xl space-y-6 overflow-y-auto p-4 sm:p-6">
      <div>
        <h1 className="font-display flex items-center gap-2.5 text-2xl font-semibold text-neutral-900 dark:text-neutral-100">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary-500">
            <ChefHat className="h-5 w-5 text-white" />
          </span>
          Validator Menu Gizi
        </h1>
        <p className="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
          Masukkan rencana menu dalam bahasa bebas. Sistem akan menganalisis nilai gizi berdasarkan
          standar MBG.
        </p>
      </div>

      <motion.div>
        <label className="mb-2 block text-sm font-medium text-neutral-700 dark:text-neutral-300">
          Kelompok Penerima Manfaat
        </label>
        <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
          {RECIPIENT_GROUPS.map((g) => (
            <button
              key={g.value}
              type="button"
              onClick={() => setRecipient(g.value)}
              className={cn(
                'flex flex-col items-center gap-1.5 rounded-xl border px-3 py-3 text-sm transition-all duration-150',
                recipient === g.value
                  ? 'border-primary-400 bg-primary-50 text-primary-700 shadow-sm dark:border-primary-600 dark:bg-primary-900/30 dark:text-primary-300'
                  : 'border-neutral-200 bg-white text-neutral-600 hover:border-neutral-300 dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-400 dark:hover:border-neutral-600'
              )}
            >
              <g.icon className="h-6 w-6 text-primary-500 shrink-0" />
              <span className="text-center text-xs font-medium leading-tight">{g.label}</span>
            </button>
          ))}
        </div>
      </motion.div>

      <div>
        <label className="mb-2 block text-sm font-medium text-neutral-700 dark:text-neutral-300">
          Rencana Menu
        </label>
        <textarea
          value={menuInput}
          onChange={(e) => setMenuInput(e.target.value)}
          rows={4}
          placeholder="Contoh: nasi putih 200g, ayam goreng 75g, tempe orek 50g, sayur bayam 100g, buah pisang 1 buah..."
          className={cn(
            'w-full resize-none rounded-2xl border border-neutral-200 bg-white px-4 py-3 text-sm',
            'text-neutral-900 placeholder:text-neutral-400 transition-colors duration-200',
            'focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-800',
            'dark:text-neutral-100 dark:focus:border-primary-600'
          )}
        />
      </div>

      <button
        type="button"
        onClick={validate}
        disabled={!menuInput.trim() || loading}
        className={cn(
          'flex w-full items-center justify-center gap-2 rounded-2xl py-3 text-sm font-semibold transition-all duration-150',
          menuInput.trim() && !loading
            ? 'bg-primary-500 text-white shadow-sm shadow-primary-500/30 hover:bg-primary-600 active:scale-[0.98]'
            : 'cursor-not-allowed bg-neutral-100 text-neutral-400 dark:bg-neutral-800'
        )}
      >
        {loading ? (
          <>
            <RefreshCw className="h-4 w-4 animate-spin" /> Menganalisis...
          </>
        ) : (
          <>
            <ChefHat className="h-4 w-4" /> Validasi Menu
          </>
        )}
      </button>

      <AnimatePresence>
        {result && statusCfg && (
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 16 }}
            transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
            className="space-y-4"
          >
            <div
              className={cn(
                'flex items-center gap-3 rounded-2xl border p-4',
                statusCfg.bg,
                statusCfg.border
              )}
            >
              <statusCfg.icon className={cn('h-6 w-6 shrink-0', statusCfg.color)} />
              <motion.div
                initial={{ opacity: 0, x: -8 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.1 }}
                className="flex-1"
              >
                <p className={cn('text-sm font-semibold', statusCfg.color)}>{statusCfg.label}</p>
                <p className="mt-0.5 text-xs text-neutral-500 dark:text-neutral-400">
                  Berdasarkan {result.regulation}
                </p>
              </motion.div>
              <div className="text-right">
                <span className={cn('font-display text-2xl font-bold', statusCfg.color)}>
                  {result.score}
                </span>
                <span className="text-xs text-neutral-400">/100</span>
              </div>
            </div>

            <div className="space-y-4 rounded-2xl border border-neutral-200 bg-white/50 p-5 dark:border-neutral-700 dark:bg-neutral-800/50">
              <h3 className="text-sm font-semibold text-neutral-900 dark:text-neutral-100">
                Rincian Nilai Gizi
              </h3>
              {result.nutrients.map((n) => (
                <NutrientBar key={n.name} nutrient={n} />
              ))}
            </div>

            {result.suggestions.length > 0 && (
              <div className="space-y-2 rounded-2xl border border-accent-200 bg-accent-50 p-4 dark:border-accent-800 dark:bg-accent-900/20">
                <h3 className="flex items-center gap-1.5 text-sm font-semibold text-accent-700 dark:text-accent-300">
                  <AlertTriangle className="h-4 w-4" /> Rekomendasi
                </h3>
                <ul className="space-y-1.5">
                  {result.suggestions.map((s, i) => (
                    <li
                      key={i}
                      className="flex items-start gap-2 text-sm text-neutral-700 dark:text-neutral-300"
                    >
                      <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-accent-400" />
                      {s}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.2 }}
              className="flex gap-2"
            >
              <button
                type="button"
                onClick={() => toast('Ekspor PDF tersedia setelah backend Fase 3')}
                className="flex flex-1 items-center justify-center gap-2 rounded-xl border border-neutral-200 bg-white py-2.5 text-sm font-medium text-neutral-700 transition-colors hover:bg-neutral-50 dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-300 dark:hover:bg-neutral-700"
              >
                <Download className="h-4 w-4" /> Unduh PDF
              </button>
              <button
                type="button"
                onClick={() => {
                  setResult(null);
                  setMenuInput('');
                }}
                className="flex items-center justify-center gap-2 rounded-xl border border-neutral-200 bg-white px-4 py-2.5 text-sm font-medium text-neutral-500 transition-colors hover:bg-neutral-50 dark:border-neutral-700 dark:bg-neutral-800 dark:hover:bg-neutral-700"
              >
                <RefreshCw className="h-4 w-4" /> Reset
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
