'use client';

import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowRight, CheckCircle2 } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import type { LandingModule } from '@/lib/landing-modules';

interface FeatureModuleDialogProps {
  module: LandingModule | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function FeatureModuleDialog({ module, open, onOpenChange }: FeatureModuleDialogProps) {
  if (!module) return null;

  const Icon = module.icon;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-lg border-0 p-0 sm:max-w-xl">
        <AnimatePresence mode="wait">
          {open && (
            <motion.div
              key={module.id}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 8 }}
              transition={{ duration: 0.35, ease: [0.16, 1, 0.3, 1] }}
            >
              <div className="relative overflow-hidden bg-gradient-to-br from-primary-500 to-primary-700 px-6 pb-8 pt-6 text-white">
                <motion.div
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ delay: 0.1, type: 'spring', stiffness: 300 }}
                  className="mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-white/20 backdrop-blur-sm"
                >
                  <Icon className="h-7 w-7" />
                </motion.div>
                <DialogHeader className="space-y-2 text-left">
                  <DialogTitle className="text-2xl text-white">{module.title}</DialogTitle>
                  <p className="text-sm font-medium text-primary-100">{module.tagline}</p>
                </DialogHeader>
                {module.regulation && (
                  <span className="mt-3 inline-block rounded-full bg-white/15 px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider">
                    {module.regulation}
                  </span>
                )}
              </div>

              <div className="space-y-5 px-6 py-5">
                <DialogDescription className="text-left text-base leading-relaxed text-neutral-700 dark:text-neutral-300">
                  {module.shortDescription}
                </DialogDescription>

                <div>
                  <h4 className="mb-2 text-xs font-semibold uppercase tracking-widest text-neutral-400">
                    Fitur utama
                  </h4>
                  <div className="flex flex-wrap gap-2">
                    {module.highlights.map((h, i) => (
                      <motion.span
                        key={h}
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ delay: 0.15 + i * 0.05 }}
                        className="rounded-lg bg-primary-50 px-2.5 py-1 text-xs font-medium text-primary-700 dark:bg-primary-900/40 dark:text-primary-300"
                      >
                        {h}
                      </motion.span>
                    ))}
                  </div>
                </div>

                <ul className="space-y-2">
                  {module.details.map((d, i) => (
                    <motion.li
                      key={d}
                      initial={{ opacity: 0, x: -8 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.2 + i * 0.06 }}
                      className="flex gap-2 text-sm text-neutral-600 dark:text-neutral-400"
                    >
                      <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0 text-primary-500" />
                      {d}
                    </motion.li>
                  ))}
                </ul>

                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.35 }}
                  className="rounded-xl border border-neutral-200 bg-neutral-50 p-3 dark:border-neutral-800 dark:bg-neutral-950"
                >
                  <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-neutral-400">
                    Contoh penggunaan
                  </p>
                  <ul className="space-y-1">
                    {module.useCases.map((u) => (
                      <li key={u} className="text-xs text-neutral-600 dark:text-neutral-400">
                        • {u}
                      </li>
                    ))}
                  </ul>
                </motion.div>
              </div>

              <DialogFooter className="border-t border-neutral-200 bg-neutral-50/80 px-6 py-4 dark:border-neutral-800 dark:bg-neutral-900/50">
                <Button variant="secondary" onClick={() => onOpenChange(false)}>
                  Tutup
                </Button>
                <Button asChild>
                  <Link href={module.href} onClick={() => onOpenChange(false)}>
                    Buka modul <ArrowRight className="h-4 w-4" />
                  </Link>
                </Button>
              </DialogFooter>
            </motion.div>
          )}
        </AnimatePresence>
      </DialogContent>
    </Dialog>
  );
}
