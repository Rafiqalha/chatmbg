'use client';

import { useRef, useState } from 'react';
import Link from 'next/link';
import { motion, useInView } from 'framer-motion';
import { ArrowRight, Sparkles, ChevronDown } from 'lucide-react';
import { ChatMBGLogo } from '@/components/brand/chatmbg-logo';
import { InteractiveBackground } from '@/components/landing/interactive-background';
import { TypingText } from '@/components/landing/typing-text';
import { FeatureModuleDialog } from '@/components/landing/feature-module-dialog';
import { LANDING_MODULES, TYPING_PHRASES, type LandingModule } from '@/lib/landing-modules';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
function ScrollSection({
  children,
  className,
  id,
}: {
  children: React.ReactNode;
  className?: string;
  id?: string;
}) {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: '-80px' });

  return (
    <motion.section
      id={id}
      ref={ref}
      initial={{ opacity: 0, y: 48 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
      className={className}
    >
      {children}
    </motion.section>
  );
}

function FeatureCard({
  module,
  index,
  onSelect,
}: {
  module: LandingModule;
  index: number;
  onSelect: (m: LandingModule) => void;
}) {
  const Icon = module.icon;

  return (
    <motion.div
      initial={{ opacity: 0, y: 32 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '-40px' }}
      transition={{ duration: 0.5, delay: index * 0.1, ease: [0.16, 1, 0.3, 1] }}
      whileHover={{ y: -6, transition: { duration: 0.2 } }}
    >
      <button
        type="button"
        onClick={() => onSelect(module)}
        className="group w-full text-left"
      >
        <Card className="h-full cursor-pointer overflow-hidden border-neutral-200/80 bg-white/70 transition-all duration-300 hover:border-primary-400 hover:shadow-lg hover:shadow-primary-500/10 dark:border-neutral-800 dark:bg-neutral-900/70 dark:hover:border-primary-600">
          <CardHeader>
            <motion.div
              whileHover={{ scale: 1.05, rotate: 3 }}
              className="mb-2 flex h-12 w-12 items-center justify-center rounded-2xl bg-primary-500 text-white shadow-md shadow-primary-500/30"
            >
              <Icon className="h-6 w-6" />
            </motion.div>
            <CardTitle className="group-hover:text-primary-600 dark:group-hover:text-primary-400">
              {module.title}
            </CardTitle>
            <CardDescription>{module.shortDescription}</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-1.5">
              {module.highlights.slice(0, 2).map((h) => (
                <span
                  key={h}
                  className="rounded-md bg-neutral-100 px-2 py-0.5 text-[10px] font-medium text-neutral-600 dark:bg-neutral-800 dark:text-neutral-400"
                >
                  {h}
                </span>
              ))}
            </div>
            <p className="mt-4 flex items-center gap-1 text-sm font-medium text-primary-600 dark:text-primary-400">
              Lihat detail
              <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-1" />
            </p>
          </CardContent>
        </Card>
      </button>
    </motion.div>
  );
}

export function LandingPage() {
  const [selectedModule, setSelectedModule] = useState<LandingModule | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);

  const openModule = (m: LandingModule) => {
    setSelectedModule(m);
    setDialogOpen(true);
  };

  return (
    <div className="relative min-h-screen">
      <InteractiveBackground />

      <header className="sticky top-0 z-40 border-b border-neutral-200/60 bg-neutral-50/80 backdrop-blur-xl dark:border-neutral-800/60 dark:bg-neutral-950/80">
        <motion.div
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6"
        >
          <Link href="/">
            <ChatMBGLogo size={40} />
          </Link>
          <nav className="hidden items-center gap-6 text-sm font-medium text-neutral-600 md:flex dark:text-neutral-400">
            <a href="#modul" className="hover:text-primary-600">
              Modul
            </a>
            <a href="#mulai" className="hover:text-primary-600">
              Mulai
            </a>
          </nav>
          <motion.div className="flex items-center gap-2">
            <Button variant="ghost" size="sm" asChild className="hidden sm:inline-flex">
              <Link href="/login">Masuk</Link>
            </Button>
            <Button size="sm" asChild>
              <Link href="/chat">
                Coba Chat <ArrowRight className="h-3.5 w-3.5" />
              </Link>
            </Button>
          </motion.div>
        </motion.div>
      </header>

      {/* Hero */}
      <section className="relative px-4 pb-24 pt-16 sm:px-6 sm:pt-24">
        <div className="mx-auto max-w-6xl text-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5 }}
            className="mb-8 flex justify-center"
          >
            <ChatMBGLogo size={72} showText={false} />
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.6 }}
          >
            <span className="inline-flex items-center gap-1.5 rounded-full border border-primary-200 bg-primary-50/80 px-3 py-1 text-xs font-semibold text-primary-700 backdrop-blur-sm dark:border-primary-800 dark:bg-primary-900/40 dark:text-primary-300">
              <Sparkles className="h-3 w-3" /> AI Intelligence Program MBG
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.6 }}
            className="font-display mx-auto mt-6 max-w-4xl text-4xl font-bold tracking-tight text-neutral-900 sm:text-6xl dark:text-neutral-50"
          >
            Satu platform untuk{' '}
            <span className="bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
              regulasi, gizi, dan supplier
            </span>{' '}
            MBG
          </motion.h1>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.35 }}
            className="mx-auto mt-6 min-h-[2rem] max-w-xl text-lg text-neutral-600 dark:text-neutral-400"
          >
            <TypingText phrases={TYPING_PHRASES} />
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
            className="mt-10 flex flex-wrap justify-center gap-3"
          >
            <Button size="lg" asChild>
              <Link href="/register">Daftar Gratis</Link>
            </Button>
            <Button size="lg" variant="secondary" asChild>
              <Link href="/chat">Langsung ke Chat</Link>
            </Button>
          </motion.div>

          <motion.div
            animate={{ y: [0, 8, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="mt-16 flex justify-center text-neutral-400"
          >
            <a href="#modul" aria-label="Scroll ke modul">
              <ChevronDown className="h-6 w-6" />
            </a>
          </motion.div>
        </div>
      </section>

      {/* Modules */}
      <ScrollSection id="modul" className="px-4 py-20 sm:px-6">
        <div className="mx-auto max-w-6xl">
          <div className="mb-12 text-center">
            <h2 className="font-display text-3xl font-bold text-neutral-900 dark:text-neutral-50">
              Empat modul eksklusif
            </h2>
            <p className="mx-auto mt-3 max-w-lg text-neutral-600 dark:text-neutral-400">
              Klik kartu untuk melihat informasi lengkap — baru masuk ke modul setelah Anda siap.
            </p>
          </div>
          <div className="grid gap-6 sm:grid-cols-2">
            {LANDING_MODULES.map((m, i) => (
              <FeatureCard key={m.id} module={m} index={i} onSelect={openModule} />
            ))}
          </div>
        </div>
      </ScrollSection>

      <FeatureModuleDialog
        module={selectedModule}
        open={dialogOpen}
        onOpenChange={setDialogOpen}
      />

      {/* CTA */}
      <ScrollSection id="mulai" className="px-4 pb-24 sm:px-6">
        <motion.div
          whileInView={{ scale: [0.98, 1] }}
          viewport={{ once: true }}
          className="mx-auto max-w-3xl overflow-hidden rounded-3xl border border-primary-200/50 bg-gradient-to-br from-primary-500 to-primary-700 p-10 text-center text-white shadow-2xl shadow-primary-500/25"
        >
          <ChatMBGLogo size={56} showText={false} className="mx-auto justify-center" />
          <h2 className="font-display mt-6 text-2xl font-bold sm:text-3xl">
            Mulai dengan ChatMBG hari ini
          </h2>
          <p className="mx-auto mt-3 max-w-md text-primary-100">
            Gratis untuk mencoba. Tanpa kartu kredit. Dirancang untuk koordinator SPPG di seluruh
            Indonesia.
          </p>
          <Button
            size="lg"
            className="mt-8 bg-white text-primary-700 hover:bg-primary-50"
            asChild
          >
            <Link href="/chat">
              Buka ChatMBG <ArrowRight className="h-4 w-4" />
            </Link>
          </Button>
        </motion.div>
      </ScrollSection>

      <footer className="border-t border-neutral-200/80 px-4 py-10 dark:border-neutral-800">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 sm:flex-row">
          <ChatMBGLogo size={32} />
          <p className="text-xs text-neutral-500">© 2026 ChatMBG · Program Makan Bergizi Gratis Indonesia</p>
        </div>
      </footer>
    </div>
  );
}
