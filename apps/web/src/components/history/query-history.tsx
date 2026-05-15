'use client';

import { motion } from 'framer-motion';
import { History, MessageSquare, ChefHat, ShieldCheck, Store } from 'lucide-react';
const DEMO_HISTORY = [
  {
    id: '1',
    module: 'chat',
    query: 'Apa syarat hyperlocal sourcing SK 244?',
    date: '15 Mei 2026, 09:32',
    icon: MessageSquare,
  },
  {
    id: '2',
    module: 'validator',
    query: 'Validasi menu: nasi, ayam, tempe, bayam',
    date: '14 Mei 2026, 14:15',
    icon: ChefHat,
  },
  {
    id: '3',
    module: 'compliance',
    query: 'Checklist supplier Katering Sejahtera',
    date: '13 Mei 2026, 11:00',
    icon: ShieldCheck,
  },
  {
    id: '4',
    module: 'suppliers',
    query: 'Cari supplier sayuran radius 10km',
    date: '12 Mei 2026, 16:45',
    icon: Store,
  },
];

const MODULE_LABELS: Record<string, string> = {
  chat: 'Regulasi',
  validator: 'Validator',
  compliance: 'Compliance',
  suppliers: 'Supplier',
};

export function QueryHistory() {
  return (
    <div className="mx-auto max-w-2xl space-y-6 overflow-y-auto p-4 sm:p-6">
      <div>
        <h1 className="font-display flex items-center gap-2.5 text-2xl font-semibold text-neutral-900 dark:text-neutral-100">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary-500">
            <History className="h-5 w-5 text-white" />
          </span>
          Riwayat Query
        </h1>
        <p className="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
          Aktivitas terbaru Anda di ChatMBG. Data penuh tersedia setelah login & backend aktif.
        </p>
      </div>

      <div className="space-y-2">
        {DEMO_HISTORY.map((item, i) => (
          <motion.div
            key={item.id}
            initial={{ opacity: 0, x: -8 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: i * 0.06 }}
            className="flex items-start gap-3 rounded-2xl border border-neutral-200 bg-white p-4 dark:border-neutral-700 dark:bg-neutral-800/50"
          >
            <motion.div
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
              transition={{ delay: i * 0.06 + 0.05 }}
              className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary-50 dark:bg-primary-900/30"
            >
              <item.icon className="h-4 w-4 text-primary-600 dark:text-primary-400" />
            </motion.div>
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2">
                <span className="rounded-full bg-neutral-100 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-neutral-600 dark:bg-neutral-700 dark:text-neutral-400">
                  {MODULE_LABELS[item.module]}
                </span>
                <span className="text-[10px] text-neutral-400">{item.date}</span>
              </div>
              <p className="mt-1 truncate text-sm text-neutral-800 dark:text-neutral-200">
                {item.query}
              </p>
            </div>
          </motion.div>
        ))}
      </div>

      <p className="text-center text-xs text-neutral-400">
        Menampilkan data demo · riwayat nyata setelah integrasi Supabase (Fase 2)
      </p>
    </div>
  );
}
