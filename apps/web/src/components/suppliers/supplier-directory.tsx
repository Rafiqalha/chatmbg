'use client';

import { useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { Store, MapPin, Users, Search, Star, BadgeCheck, Filter } from 'lucide-react';
import { cn } from '@/lib/utils';
import { DEMO_SUPPLIERS } from '@/lib/mock/demo-data';

export function SupplierDirectory() {
  const [query, setQuery] = useState('');
  const [radius, setRadius] = useState(20);
  const [verifiedOnly, setVerifiedOnly] = useState(false);

  const filtered = useMemo(() => {
    return DEMO_SUPPLIERS.filter((s) => {
      if (verifiedOnly && !s.verified) return false;
      if (s.distanceKm > radius) return false;
      if (query && !s.name.toLowerCase().includes(query.toLowerCase())) return false;
      return true;
    });
  }, [query, radius, verifiedOnly]);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.3 }}
      className="mx-auto max-w-3xl space-y-6 overflow-y-auto p-4 sm:p-6"
    >
      <div>
        <h1 className="font-display flex items-center gap-2.5 text-2xl font-semibold text-neutral-900 dark:text-neutral-100">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary-500">
            <Store className="h-5 w-5 text-white" />
          </span>
          Direktori UMKM Supplier
        </h1>
        <p className="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
          Cari supplier MBG terdekat berdasarkan lokasi, kapasitas, dan status verifikasi.
        </p>
      </div>

      <div className="space-y-3 rounded-2xl border border-neutral-200 bg-white p-4 dark:border-neutral-700 dark:bg-neutral-800/50">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-neutral-400" />
          <input
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Cari nama supplier atau kategori..."
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 py-2.5 pl-10 pr-4 text-sm focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-900 dark:text-neutral-100"
          />
        </div>
        <motion.div
          initial={{ opacity: 0, y: 6 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.05 }}
          className="flex flex-wrap items-center gap-3"
        >
          <div className="flex items-center gap-2 text-sm text-neutral-600 dark:text-neutral-400">
            <Filter className="h-4 w-4" />
            <span>Radius: {radius} km</span>
          </div>
          <input
            type="range"
            min={5}
            max={50}
            step={5}
            value={radius}
            onChange={(e) => setRadius(Number(e.target.value))}
            className="h-1.5 flex-1 accent-primary-500"
          />
          <label className="flex cursor-pointer items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={verifiedOnly}
              onChange={(e) => setVerifiedOnly(e.target.checked)}
              className="rounded border-neutral-300 accent-primary-500"
            />
            <span className="text-neutral-600 dark:text-neutral-400">Hanya terverifikasi</span>
          </label>
        </motion.div>
      </div>

      <p className="text-sm text-neutral-500">
        {filtered.length} supplier ditemukan · Mode demo
      </p>

      <div className="space-y-3">
        {filtered.map((s, i) => (
          <motion.div
            key={s.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.06, duration: 0.25 }}
            className="rounded-2xl border border-neutral-200 bg-white p-4 transition-all hover:border-primary-300 hover:shadow-sm dark:border-neutral-700 dark:bg-neutral-800 dark:hover:border-primary-700"
          >
            <div className="flex items-start justify-between gap-3">
              <div>
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: i * 0.06 + 0.1 }}
                  className="flex items-center gap-2"
                >
                  <h3 className="font-semibold text-neutral-900 dark:text-neutral-100">
                    {s.name}
                  </h3>
                  {s.verified && (
                    <BadgeCheck className="h-4 w-4 text-primary-500" aria-label="Terverifikasi" />
                  )}
                </motion.div>
                <p className="mt-0.5 text-sm text-primary-600 dark:text-primary-400">
                  {s.category}
                </p>
              </div>
              <motion.div
                initial={{ scale: 0.9, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ delay: i * 0.06 + 0.15 }}
                className="text-right"
              >
                <div className="flex items-center gap-1 text-sm font-medium text-neutral-700 dark:text-neutral-300">
                  <Star className="h-3.5 w-3.5 fill-accent-400 text-accent-400" />
                  {s.completeness}%
                </div>
                <p className="text-[10px] text-neutral-400">kelengkapan profil</p>
              </motion.div>
            </div>
            <div className="mt-3 flex flex-wrap gap-4 text-xs text-neutral-500">
              <span className="flex items-center gap-1">
                <MapPin className="h-3.5 w-3.5" /> {s.distanceKm} km
              </span>
              <span className="flex items-center gap-1">
                <Users className="h-3.5 w-3.5" /> {s.capacity} porsi/hari
              </span>
            </div>
            <button
              type="button"
              className="mt-3 w-full rounded-xl border border-primary-200 py-2 text-sm font-medium text-primary-700 transition-colors hover:bg-primary-50 dark:border-primary-800 dark:text-primary-300 dark:hover:bg-primary-900/20"
            >
              Lihat Profil & Hubungi
            </button>
          </motion.div>
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="rounded-2xl border border-dashed border-neutral-300 p-8 text-center dark:border-neutral-700">
          <Store className="mx-auto h-10 w-10 text-neutral-300" />
          <p className="mt-2 text-sm text-neutral-500">Tidak ada supplier sesuai filter.</p>
        </div>
      )}
    </motion.div>
  );
}
