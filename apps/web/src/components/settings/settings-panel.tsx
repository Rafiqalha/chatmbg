'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { Settings, User, Bell, Key, LogOut, Leaf } from 'lucide-react';
import Link from 'next/link';
import { useTheme } from 'next-themes';
import toast from 'react-hot-toast';
import { cn } from '@/lib/utils';

export function SettingsPanel() {
  const { theme, setTheme } = useTheme();
  const [notifications, setNotifications] = useState(true);

  return (
    <div className="mx-auto max-w-2xl space-y-6 overflow-y-auto p-4 sm:p-6">
      <motion.div
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
      >
        <h1 className="font-display flex items-center gap-2.5 text-2xl font-semibold text-neutral-900 dark:text-neutral-100">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary-500">
            <Settings className="h-5 w-5 text-white" />
          </span>
          Pengaturan
        </h1>
        <p className="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
          Kelola akun, preferensi tampilan, dan notifikasi ChatMBG.
        </p>
      </motion.div>

      <div className="flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 dark:border-neutral-700 dark:bg-neutral-800/50">
        <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary-500">
          <Leaf className="h-7 w-7 text-white" />
        </div>
        <div>
          <p className="font-semibold text-neutral-900 dark:text-neutral-100">Pengguna Demo</p>
          <p className="text-sm text-neutral-500">demo@mbgbrain.id · Koordinator SPPG</p>
          <Link
            href="/login"
            className="mt-1 inline-block text-sm font-medium text-primary-600 hover:underline dark:text-primary-400"
          >
            Masuk dengan akun Supabase →
          </Link>
        </div>
      </div>

      <section className="space-y-2">
        <h2 className="px-1 text-xs font-semibold uppercase tracking-widest text-neutral-400">
          Preferensi
        </h2>
        <div className="overflow-hidden rounded-2xl border border-neutral-200 bg-white dark:border-neutral-700 dark:bg-neutral-800/50">
          <button
            type="button"
            onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
            className="flex w-full items-center justify-between border-b border-neutral-100 px-4 py-3.5 text-left dark:border-neutral-700"
          >
            <span className="flex items-center gap-3 text-sm text-neutral-700 dark:text-neutral-300">
              <User className="h-4 w-4 text-neutral-400" />
              Tema tampilan
            </span>
            <span className="text-sm font-medium text-primary-600 capitalize dark:text-primary-400">
              {theme === 'dark' ? 'Gelap' : theme === 'light' ? 'Terang' : 'Sistem'}
            </span>
          </button>
          <label className="flex cursor-pointer items-center justify-between px-4 py-3.5">
            <span className="flex items-center gap-3 text-sm text-neutral-700 dark:text-neutral-300">
              <Bell className="h-4 w-4 text-neutral-400" />
              Notifikasi pembaruan regulasi
            </span>
            <input
              type="checkbox"
              checked={notifications}
              onChange={(e) => setNotifications(e.target.checked)}
              className="h-4 w-4 rounded accent-primary-500"
            />
          </label>
        </div>
      </section>

      <section className="space-y-2">
        <h2 className="px-1 text-xs font-semibold uppercase tracking-widest text-neutral-400">
          API & Langganan
        </h2>
        <div className="overflow-hidden rounded-2xl border border-neutral-200 bg-white dark:border-neutral-700 dark:bg-neutral-800/50">
          <button
            type="button"
            onClick={() => toast('Kelola API key tersedia di Fase 3')}
            className="flex w-full items-center gap-3 border-b border-neutral-100 px-4 py-3.5 text-sm text-neutral-700 dark:border-neutral-700 dark:text-neutral-300"
          >
            <Key className="h-4 w-4 text-neutral-400" />
            Kelola API Keys
          </button>
          <div className="px-4 py-3.5">
            <p className="text-sm font-medium text-neutral-900 dark:text-neutral-100">
              Paket: ChatMBG Lite (Demo)
            </p>
            <p className="mt-0.5 text-xs text-neutral-500">50 query/bulan · Upgrade ke Pro SPPG</p>
          </div>
        </div>
      </section>

      <button
        type="button"
        onClick={() => toast('Logout tersedia setelah auth Supabase')}
        className={cn(
          'flex w-full items-center justify-center gap-2 rounded-2xl border border-red-200 py-3 text-sm font-medium text-red-600',
          'transition-colors hover:bg-red-50 dark:border-red-900 dark:text-red-400 dark:hover:bg-red-900/20'
        )}
      >
        <LogOut className="h-4 w-4" />
        Keluar
      </button>
    </div>
  );
}
