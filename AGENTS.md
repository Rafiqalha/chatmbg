# AGENTS.md — MBGBrain AI Agent Execution Playbook

> **Dokumen ini adalah panduan eksekusi bertahap untuk AI agent dalam membangun platform MBGBrain.**
> Setiap fase harus diselesaikan secara berurutan. Jangan melompat fase.
> Referensi utama: `PRD.md` versi 1.0.0 — 15 Mei 2026.

---

## Konvensi Dokumen Ini

- `[AGENT ACTION]` — instruksi eksplisit yang harus dieksekusi agent
- `[VERIFY]` — checkpoint validasi sebelum lanjut ke step berikutnya
- `[FILE: path/ke/file]` — file yang harus dibuat atau dimodifikasi
- `⚠️ CRITICAL` — kesalahan di sini akan menyebabkan kegagalan downstream
- `💡 CONTEXT` — latar belakang domain yang dibutuhkan agent

---

## Struktur Monorepo

```
mbgbrain/
├── AGENTS.md                    ← dokumen ini
├── PRD.md                       ← referensi requirements
├── .env.example                 ← template environment variables
├── docker-compose.yml           ← local dev orchestration
│
├── apps/
│   ├── web/                     ← Next.js 14 (frontend utama)
│   ├── mobile/                  ← Flutter (post-MVP, fase 5)
│   └── api/                     ← FastAPI (backend)
│
├── packages/
│   ├── ui/                      ← shared design system (Next.js)
│   ├── types/                   ← shared TypeScript types
│   └── config/                  ← shared ESLint, Tailwind config
│
├── supabase/
│   ├── migrations/              ← SQL migration files
│   ├── seed/                    ← seed data untuk development
│   └── functions/               ← Supabase Edge Functions
│
├── scripts/
│   ├── ingest/                  ← pipeline ingesti dokumen regulasi
│   └── eval/                    ← evaluasi akurasi RAG
│
└── docs/
    ├── api/                     ← dokumentasi API (OpenAPI)
    └── architecture/            ← diagram arsitektur
```

---

## Fase 0 — Setup & Fondasi (Hari 0)

### 0.1 — Inisialisasi Monorepo

```bash
[AGENT ACTION]
mkdir mbgbrain && cd mbgbrain
git init
git branch -M main

# Setup pnpm workspace
npm install -g pnpm
pnpm init

# Buat pnpm-workspace.yaml
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'apps/*'
  - 'packages/*'
EOF
```

### 0.2 — Environment Variables

```bash
[AGENT ACTION]
# Buat file .env.example di root
```

```ini
[FILE: .env.example]
# ── Supabase ──────────────────────────────────────────────────
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_DB_URL=postgresql://postgres:password@db.your-project.supabase.co:5432/postgres

# ── LLM Providers ─────────────────────────────────────────────
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# ── App Config ────────────────────────────────────────────────
NEXT_PUBLIC_APP_URL=http://localhost:3000
API_BASE_URL=http://localhost:8000
NEXT_PUBLIC_API_URL=http://localhost:8000

# ── Sentry (monitoring) ───────────────────────────────────────
SENTRY_DSN=https://...@sentry.io/...
NEXT_PUBLIC_SENTRY_DSN=https://...@sentry.io/...

# ── Rate Limiting ─────────────────────────────────────────────
DEFAULT_RATE_LIMIT_PER_MIN=100
FREE_TIER_MONTHLY_QUERIES=50
```

---

## Fase 1 — UI/UX Design System & Frontend (Hari 1–7)

> **Mulai dari sini. UI/UX adalah prioritas pertama.**
> Target: Antarmuka yang terasa seperti ChatGPT/Claude tapi dengan identitas visual MBG (hijau organik, hangat, modern).

### 1.1 — Inisialisasi Next.js App

```bash
[AGENT ACTION]
cd apps
pnpm create next-app@latest web \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --no-turbo
cd web
pnpm add @supabase/supabase-js @supabase/ssr
pnpm add lucide-react
pnpm add framer-motion
pnpm add @radix-ui/react-dialog @radix-ui/react-dropdown-menu @radix-ui/react-tooltip @radix-ui/react-avatar @radix-ui/react-scroll-area
pnpm add clsx tailwind-merge class-variance-authority
pnpm add react-markdown remark-gfm rehype-highlight
pnpm add @tanstack/react-query
pnpm add react-hot-toast
pnpm add next-themes
pnpm add @vercel/analytics
```

### 1.2 — Design Token System

```typescript
[FILE: apps/web/src/lib/design-tokens.ts]
/**
 * MBGBrain Design System
 * Tema: "Hijau Gizi" — modern, organik, terpercaya
 * Inspirasi: warna daun pandan, kunyit, bayam — pangan Indonesia
 */

export const colors = {
  // Primary — Hijau Organik (bayam/pandan)
  primary: {
    50:  '#f0faf4',
    100: '#d8f3e3',
    200: '#b4e6c8',
    300: '#82d1a6',
    400: '#4bb87e',
    500: '#2a9d5c',  // brand utama
    600: '#1e7d47',
    700: '#196339',
    800: '#154f2e',
    900: '#0f3a21',
  },
  // Accent — Kunyit / Amber hangat
  accent: {
    50:  '#fffbeb',
    100: '#fef3c7',
    200: '#fde68a',
    300: '#fcd34d',
    400: '#f59e0b',  // kunyit
    500: '#d97706',
    600: '#b45309',
    700: '#92400e',
    800: '#78350f',
    900: '#451a03',
  },
  // Neutral — Beras / Krem
  neutral: {
    50:  '#fafaf8',
    100: '#f5f4f0',
    200: '#e9e7e0',
    300: '#d4d1c7',
    400: '#b5b2a5',
    500: '#8f8c82',
    600: '#6b6860',
    700: '#524f48',
    800: '#3d3b35',
    900: '#27251f',
  },
  // Semantic
  danger:  '#dc2626',
  warning: '#f59e0b',
  success: '#2a9d5c',
  info:    '#3b82f6',
} as const;

export const typography = {
  // Display: Karakter kuat, modern Indonesia
  fontDisplay: '"Plus Jakarta Sans", "Noto Sans", sans-serif',
  // Body: Readable, bersih
  fontBody: '"DM Sans", "Noto Sans", system-ui, sans-serif',
  // Mono: Untuk kode dan data
  fontMono: '"JetBrains Mono", "Fira Code", monospace',
} as const;
```

### 1.3 — Tailwind Config

```typescript
[FILE: apps/web/tailwind.config.ts]
import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: ['class'],
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary:   { DEFAULT: '#2a9d5c', ...{ 50:'#f0faf4',100:'#d8f3e3',200:'#b4e6c8',300:'#82d1a6',400:'#4bb87e',500:'#2a9d5c',600:'#1e7d47',700:'#196339',800:'#154f2e',900:'#0f3a21' } },
        accent:    { DEFAULT: '#f59e0b', ...{ 50:'#fffbeb',100:'#fef3c7',200:'#fde68a',300:'#fcd34d',400:'#f59e0b',500:'#d97706',600:'#b45309' } },
        neutral:   { DEFAULT: '#8f8c82', ...{ 50:'#fafaf8',100:'#f5f4f0',200:'#e9e7e0',300:'#d4d1c7',400:'#b5b2a5',500:'#8f8c82',600:'#6b6860',700:'#524f48',800:'#3d3b35',900:'#27251f' } },
      },
      fontFamily: {
        display: ['"Plus Jakarta Sans"', '"Noto Sans"', 'sans-serif'],
        body:    ['"DM Sans"', '"Noto Sans"', 'system-ui', 'sans-serif'],
        mono:    ['"JetBrains Mono"', '"Fira Code"', 'monospace'],
      },
      borderRadius: {
        'xl':  '12px',
        '2xl': '16px',
        '3xl': '24px',
      },
      animation: {
        'fade-in':     'fadeIn 0.3s ease-out',
        'slide-up':    'slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1)',
        'slide-in':    'slideIn 0.3s ease-out',
        'pulse-slow':  'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'typing':      'typing 1.4s steps(3, end) infinite',
      },
      keyframes: {
        fadeIn:  { from: { opacity: '0' }, to: { opacity: '1' } },
        slideUp: { from: { transform: 'translateY(12px)', opacity: '0' }, to: { transform: 'translateY(0)', opacity: '1' } },
        slideIn: { from: { transform: 'translateX(-8px)', opacity: '0' }, to: { transform: 'translateX(0)', opacity: '1' } },
        typing:  { '0%,100%': { opacity: '1' }, '50%': { opacity: '0.3' } },
      },
      backgroundImage: {
        'grain':        "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.04'/%3E%3C/svg%3E\")",
        'grid-pattern': "url(\"data:image/svg+xml,%3Csvg width='40' height='40' viewBox='0 0 40 40' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' stroke='%232a9d5c' stroke-opacity='0.06'%3E%3Cpath d='M0 0h40v40H0z'/%3E%3C/g%3E%3C/svg%3E\")",
      },
    },
  },
  plugins: [],
};

export default config;
```

### 1.4 — Global CSS & Font Loading

```css
[FILE: apps/web/src/app/globals.css]
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&family=JetBrains+Mono:wght@400;500&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 250 250 248;
    --foreground: 39 37 31;
    --surface:    245 244 240;
    --border:     212 209 199;
    --primary:    42 157 92;
    --accent:     245 158 11;
    --radius:     12px;
  }

  .dark {
    --background: 22 21 18;
    --foreground: 250 249 246;
    --surface:    33 31 27;
    --border:     61 59 53;
  }

  * {
    @apply border-neutral-200 dark:border-neutral-700;
  }

  body {
    @apply bg-neutral-50 text-neutral-900 font-body antialiased;
    font-feature-settings: "rlig" 1, "calt" 1;
  }

  h1, h2, h3, h4 {
    @apply font-display font-semibold tracking-tight;
  }

  /* Scrollbar custom */
  ::-webkit-scrollbar       { width: 6px; height: 6px; }
  ::-webkit-scrollbar-track { @apply bg-transparent; }
  ::-webkit-scrollbar-thumb { @apply bg-neutral-300 dark:bg-neutral-600 rounded-full; }
  ::-webkit-scrollbar-thumb:hover { @apply bg-neutral-400 dark:bg-neutral-500; }
}

@layer utilities {
  .glass {
    backdrop-filter: blur(16px) saturate(180%);
    -webkit-backdrop-filter: blur(16px) saturate(180%);
    background: rgba(250, 250, 248, 0.85);
  }
  .dark .glass {
    background: rgba(22, 21, 18, 0.85);
  }

  .text-balance { text-wrap: balance; }
  .grain-overlay { background-image: url("data:image/svg+xml,..."); }
}
```

### 1.5 — Root Layout

```tsx
[FILE: apps/web/src/app/layout.tsx]
import type { Metadata, Viewport } from 'next';
import { ThemeProvider } from '@/components/providers/theme-provider';
import { QueryProvider } from '@/components/providers/query-provider';
import { Toaster } from 'react-hot-toast';
import { Analytics } from '@vercel/analytics/react';
import './globals.css';

export const metadata: Metadata = {
  title: {
    default: 'MBGBrain — AI Intelligence untuk Program Makan Bergizi Gratis',
    template: '%s | MBGBrain',
  },
  description: 'Platform AI untuk SPPG, UMKM, dan ekosistem Makan Bergizi Gratis Indonesia. Validasi menu, cek regulasi, dan matching supplier dalam satu platform.',
  keywords: ['MBG', 'Makan Bergizi Gratis', 'SPPG', 'AI', 'regulasi', 'gizi'],
  authors: [{ name: 'MBGBrain' }],
  openGraph: {
    type:   'website',
    locale: 'id_ID',
    url:    'https://mbgbrain.id',
    title:  'MBGBrain — AI Intelligence untuk MBG Indonesia',
    description: 'Validasi menu, cek regulasi SK 244, dan matching UMKM supplier.',
    siteName: 'MBGBrain',
  },
  robots: { index: true, follow: true },
  icons: { icon: '/favicon.ico', apple: '/apple-touch-icon.png' },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#f5f4f0' },
    { media: '(prefers-color-scheme: dark)',  color: '#161512' },
  ],
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="id" suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          <QueryProvider>
            {children}
            <Toaster
              position="bottom-center"
              toastOptions={{
                style: {
                  background: 'var(--surface)',
                  color: 'var(--foreground)',
                  border: '1px solid var(--border)',
                  borderRadius: '12px',
                  fontFamily: '"DM Sans", sans-serif',
                },
              }}
            />
          </QueryProvider>
        </ThemeProvider>
        <Analytics />
      </body>
    </html>
  );
}
```

### 1.6 — Komponen UI Inti

#### 1.6.1 — Sidebar (Navigation)

```tsx
[FILE: apps/web/src/components/layout/sidebar.tsx]
/**
 * Sidebar — mirip Claude/ChatGPT sidebar
 * Fitur: riwayat percakapan, navigasi modul, user profile
 */
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import {
  MessageSquare, ChefHat, ShieldCheck, Store,
  History, Settings, ChevronLeft, ChevronRight,
  Plus, LogOut, Moon, Sun, Leaf
} from 'lucide-react';
import { useTheme } from 'next-themes';
import { cn } from '@/lib/utils';

const NAV_ITEMS = [
  {
    group: 'Asisten AI',
    items: [
      { href: '/chat',       icon: MessageSquare, label: 'Regulasi Assistant',  badge: null },
      { href: '/validator',  icon: ChefHat,       label: 'Validator Menu Gizi', badge: 'NEW' },
      { href: '/compliance', icon: ShieldCheck,   label: 'Cek Kepatuhan SK 244', badge: null },
      { href: '/suppliers',  icon: Store,         label: 'Direktori UMKM',      badge: null },
    ],
  },
  {
    group: 'Riwayat',
    items: [
      { href: '/history', icon: History, label: 'Riwayat Query', badge: null },
    ],
  },
];

interface SidebarProps {
  className?: string;
}

export function Sidebar({ className }: SidebarProps) {
  const [collapsed, setCollapsed] = useState(false);
  const pathname  = usePathname();
  const { theme, setTheme } = useTheme();

  return (
    <motion.aside
      animate={{ width: collapsed ? 64 : 260 }}
      transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
      className={cn(
        'relative flex h-screen flex-col border-r border-neutral-200 dark:border-neutral-800',
        'bg-neutral-50 dark:bg-neutral-900',
        className
      )}
    >
      {/* Logo */}
      <div className="flex h-16 items-center px-4 border-b border-neutral-200 dark:border-neutral-800">
        <div className="flex items-center gap-2.5 overflow-hidden">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-primary-500">
            <Leaf className="h-4 w-4 text-white" />
          </div>
          <AnimatePresence>
            {!collapsed && (
              <motion.div
                initial={{ opacity: 0, x: -8 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -8 }}
                transition={{ duration: 0.15 }}
              >
                <span className="font-display font-bold text-neutral-900 dark:text-neutral-50 text-[15px] leading-none">
                  MBG<span className="text-primary-500">Brain</span>
                </span>
                <p className="text-[10px] text-neutral-500 mt-0.5">AI Intelligence MBG</p>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* New Chat Button */}
      <div className="p-3">
        <Link
          href="/chat"
          className={cn(
            'flex items-center gap-2.5 rounded-xl px-3 py-2.5 text-sm font-medium',
            'bg-primary-500 text-white hover:bg-primary-600',
            'transition-all duration-150 active:scale-95',
            collapsed && 'justify-center px-0'
          )}
        >
          <Plus className="h-4 w-4 shrink-0" />
          {!collapsed && <span>Mulai Chat Baru</span>}
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto px-3 pb-2 space-y-4">
        {NAV_ITEMS.map((group) => (
          <div key={group.group}>
            {!collapsed && (
              <p className="mb-1 px-2 text-[10px] font-semibold uppercase tracking-widest text-neutral-400 dark:text-neutral-600">
                {group.group}
              </p>
            )}
            <ul className="space-y-0.5">
              {group.items.map((item) => {
                const active = pathname.startsWith(item.href);
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      className={cn(
                        'group flex items-center gap-2.5 rounded-xl px-3 py-2 text-sm',
                        'transition-all duration-150',
                        active
                          ? 'bg-primary-50 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 font-medium'
                          : 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-100 dark:hover:bg-neutral-800 hover:text-neutral-900 dark:hover:text-neutral-100',
                        collapsed && 'justify-center px-0 w-10 mx-auto'
                      )}
                      title={collapsed ? item.label : undefined}
                    >
                      <item.icon className={cn('h-4 w-4 shrink-0', active && 'text-primary-600 dark:text-primary-400')} />
                      {!collapsed && (
                        <>
                          <span className="flex-1 truncate">{item.label}</span>
                          {item.badge && (
                            <span className="rounded-full bg-accent-400/20 px-1.5 py-0.5 text-[9px] font-bold text-accent-700 dark:text-accent-300">
                              {item.badge}
                            </span>
                          )}
                        </>
                      )}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      {/* Bottom actions */}
      <div className="border-t border-neutral-200 dark:border-neutral-800 p-3 space-y-1">
        <button
          onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
          className={cn(
            'flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-sm',
            'text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800 hover:text-neutral-900 dark:hover:text-neutral-100',
            'transition-all duration-150',
            collapsed && 'justify-center px-0 w-10 mx-auto'
          )}
        >
          {theme === 'dark' ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          {!collapsed && <span>Tampilan {theme === 'dark' ? 'Terang' : 'Gelap'}</span>}
        </button>

        <Link
          href="/settings"
          className={cn(
            'flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-sm',
            'text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800 hover:text-neutral-900 dark:hover:text-neutral-100',
            'transition-all duration-150',
            collapsed && 'justify-center px-0 w-10 mx-auto'
          )}
        >
          <Settings className="h-4 w-4" />
          {!collapsed && <span>Pengaturan</span>}
        </Link>
      </div>

      {/* Collapse toggle */}
      <button
        onClick={() => setCollapsed(!collapsed)}
        className={cn(
          'absolute -right-3 top-20 z-10 flex h-6 w-6 items-center justify-center',
          'rounded-full border border-neutral-200 dark:border-neutral-700',
          'bg-white dark:bg-neutral-900 text-neutral-500',
          'hover:bg-neutral-50 dark:hover:bg-neutral-800',
          'shadow-sm transition-all duration-150'
        )}
      >
        {collapsed ? <ChevronRight className="h-3 w-3" /> : <ChevronLeft className="h-3 w-3" />}
      </button>
    </motion.aside>
  );
}
```

#### 1.6.2 — Chat Interface (Modul Utama)

```tsx
[FILE: apps/web/src/components/chat/chat-interface.tsx]
/**
 * Chat Interface — antarmuka utama MBGBrain
 * Mirip Claude/ChatGPT tapi dengan identitas MBG:
 * - Bubble hijau untuk AI response
 * - Citation regulasi yang bisa di-expand
 * - Typing indicator animasi
 * - Empty state dengan quick prompts
 */
'use client';

import { useState, useRef, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Send, Paperclip, Mic, StopCircle, RefreshCw, Copy, ThumbsUp, ThumbsDown, Leaf, BookOpen, AlertCircle } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { cn } from '@/lib/utils';

// ─── Types ───────────────────────────────────────────────────────────────────

interface Citation {
  regulation: string;  // e.g. "SK 244/2025"
  article:    string;  // e.g. "Pasal 12 Ayat 3"
  excerpt:    string;  // kutipan relevan
}

interface Message {
  id:        string;
  role:      'user' | 'assistant';
  content:   string;
  citations?: Citation[];
  timestamp: Date;
  status:    'pending' | 'streaming' | 'done' | 'error';
}

// ─── Quick Prompts (Empty State) ─────────────────────────────────────────────

const QUICK_PROMPTS = [
  { icon: '📋', text: 'Apa syarat menjadi supplier resmi MBG?', category: 'UMKM' },
  { icon: '🥗', text: 'Validasi menu: nasi, ayam, tempe, sayur bayam, pisang untuk siswa SD', category: 'Validator' },
  { icon: '🔍', text: 'Jelaskan kewajiban hyperlocal sourcing dalam SK 244/2025', category: 'Regulasi' },
  { icon: '📊', text: 'Dokumen apa yang dibutuhkan untuk persiapan audit BPKP?', category: 'Compliance' },
];

// ─── Citation Card ────────────────────────────────────────────────────────────

function CitationCard({ citations }: { citations: Citation[] }) {
  const [expanded, setExpanded] = useState(false);
  return (
    <div className="mt-3 rounded-xl border border-primary-200 dark:border-primary-800/50 bg-primary-50 dark:bg-primary-900/20 overflow-hidden">
      <button
        onClick={() => setExpanded(!expanded)}
        className="flex w-full items-center gap-2 px-3 py-2 text-left"
      >
        <BookOpen className="h-3.5 w-3.5 text-primary-600 dark:text-primary-400 shrink-0" />
        <span className="text-xs font-medium text-primary-700 dark:text-primary-300 flex-1">
          {citations.length} sumber regulasi
        </span>
        <span className="text-xs text-primary-500">{expanded ? '▲' : '▼'}</span>
      </button>
      <AnimatePresence>
        {expanded && (
          <motion.div
            initial={{ height: 0 }} animate={{ height: 'auto' }} exit={{ height: 0 }}
            className="overflow-hidden"
          >
            <div className="border-t border-primary-200 dark:border-primary-800/50 divide-y divide-primary-100 dark:divide-primary-800/30">
              {citations.map((c, i) => (
                <div key={i} className="px-3 py-2">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="rounded-md bg-primary-500 px-1.5 py-0.5 text-[10px] font-bold text-white">{c.regulation}</span>
                    <span className="text-[11px] text-primary-600 dark:text-primary-400 font-medium">{c.article}</span>
                  </div>
                  <p className="text-xs text-neutral-600 dark:text-neutral-400 leading-relaxed italic">"{c.excerpt}"</p>
                </div>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────

function TypingIndicator() {
  return (
    <div className="flex items-center gap-1.5 px-4 py-3">
      <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary-500 shrink-0">
        <Leaf className="h-4 w-4 text-white" />
      </div>
      <div className="flex items-center gap-1 rounded-2xl bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 px-4 py-3">
        {[0, 1, 2].map((i) => (
          <motion.div
            key={i}
            className="h-1.5 w-1.5 rounded-full bg-primary-400"
            animate={{ opacity: [0.3, 1, 0.3], scale: [0.8, 1.2, 0.8] }}
            transition={{ duration: 1.2, repeat: Infinity, delay: i * 0.2 }}
          />
        ))}
      </div>
    </div>
  );
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

function MessageBubble({ message, isLast }: { message: Message; isLast: boolean }) {
  const isUser = message.role === 'user';

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y:  0 }}
      transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
      className={cn('group flex gap-3 px-4 py-2', isUser && 'flex-row-reverse')}
    >
      {/* Avatar */}
      {!isUser && (
        <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary-500 mt-1">
          <Leaf className="h-4 w-4 text-white" />
        </div>
      )}

      {/* Content */}
      <div className={cn('max-w-[80%] space-y-1', isUser && 'items-end flex flex-col')}>
        {isUser ? (
          <div className="rounded-2xl rounded-tr-sm bg-primary-500 px-4 py-3 text-white text-sm leading-relaxed">
            {message.content}
          </div>
        ) : (
          <div className="rounded-2xl rounded-tl-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 px-4 py-3">
            {message.status === 'error' ? (
              <div className="flex items-center gap-2 text-sm text-red-600 dark:text-red-400">
                <AlertCircle className="h-4 w-4" />
                <span>Terjadi kesalahan. Coba lagi.</span>
              </div>
            ) : (
              <div className="text-sm text-neutral-800 dark:text-neutral-200 leading-relaxed prose prose-sm dark:prose-invert max-w-none prose-p:my-1 prose-headings:font-display">
                <ReactMarkdown remarkPlugins={[remarkGfm]}>
                  {message.content}
                </ReactMarkdown>
              </div>
            )}
            {message.citations && message.citations.length > 0 && (
              <CitationCard citations={message.citations} />
            )}
          </div>
        )}

        {/* Actions (hover) */}
        {!isUser && message.status === 'done' && (
          <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity duration-150">
            <ActionButton icon={Copy}      title="Salin" onClick={() => navigator.clipboard.writeText(message.content)} />
            <ActionButton icon={ThumbsUp}  title="Membantu" onClick={() => {}} />
            <ActionButton icon={ThumbsDown} title="Tidak membantu" onClick={() => {}} />
            {isLast && <ActionButton icon={RefreshCw} title="Coba lagi" onClick={() => {}} />}
          </div>
        )}
      </div>
    </motion.div>
  );
}

function ActionButton({ icon: Icon, title, onClick }: { icon: any; title: string; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      title={title}
      className="flex h-7 w-7 items-center justify-center rounded-lg text-neutral-400 hover:bg-neutral-100 dark:hover:bg-neutral-800 hover:text-neutral-600 dark:hover:text-neutral-300 transition-all"
    >
      <Icon className="h-3.5 w-3.5" />
    </button>
  );
}

// ─── Empty State ──────────────────────────────────────────────────────────────

function EmptyState({ onPromptClick }: { onPromptClick: (text: string) => void }) {
  return (
    <div className="flex flex-1 flex-col items-center justify-center p-8 text-center">
      <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.4 }}>
        {/* Hero icon */}
        <div className="mb-6 flex items-center justify-center">
          <div className="relative">
            <div className="h-20 w-20 rounded-3xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center shadow-lg shadow-primary-500/25">
              <Leaf className="h-10 w-10 text-white" />
            </div>
            <div className="absolute -bottom-1 -right-1 h-6 w-6 rounded-full bg-accent-400 flex items-center justify-center text-xs font-bold text-white">AI</div>
          </div>
        </div>

        <h1 className="font-display text-2xl font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
          Selamat datang di MBGBrain
        </h1>
        <p className="text-sm text-neutral-500 dark:text-neutral-400 max-w-sm mb-8">
          Asisten AI untuk program Makan Bergizi Gratis. Tanyakan regulasi, validasi menu, atau cari supplier UMKM.
        </p>

        {/* Quick prompts */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 max-w-lg">
          {QUICK_PROMPTS.map((p, i) => (
            <motion.button
              key={i}
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 + i * 0.05 }}
              onClick={() => onPromptClick(p.text)}
              className={cn(
                'group flex items-start gap-3 rounded-2xl border border-neutral-200 dark:border-neutral-700',
                'bg-white dark:bg-neutral-800/50 p-3.5 text-left',
                'hover:border-primary-300 dark:hover:border-primary-700',
                'hover:bg-primary-50 dark:hover:bg-primary-900/20',
                'transition-all duration-200 active:scale-[0.98]'
              )}
            >
              <span className="text-xl">{p.icon}</span>
              <div>
                <span className="block text-[10px] font-semibold uppercase tracking-wider text-primary-500 mb-0.5">{p.category}</span>
                <span className="text-sm text-neutral-700 dark:text-neutral-300 leading-snug">{p.text}</span>
              </div>
            </motion.button>
          ))}
        </div>
      </motion.div>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export function ChatInterface() {
  const [messages,   setMessages]   = useState<Message[]>([]);
  const [input,      setInput]      = useState('');
  const [isLoading,  setIsLoading]  = useState(false);
  const bottomRef  = useRef<HTMLDivElement>(null);
  const inputRef   = useRef<HTMLTextAreaElement>(null);

  // Auto-scroll
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  // Auto-resize textarea
  useEffect(() => {
    if (inputRef.current) {
      inputRef.current.style.height = 'auto';
      inputRef.current.style.height = Math.min(inputRef.current.scrollHeight, 160) + 'px';
    }
  }, [input]);

  const sendMessage = useCallback(async (text?: string) => {
    const content = (text ?? input).trim();
    if (!content || isLoading) return;

    const userMsg: Message = {
      id:        crypto.randomUUID(),
      role:      'user',
      content,
      timestamp: new Date(),
      status:    'done',
    };

    const assistantMsg: Message = {
      id:        crypto.randomUUID(),
      role:      'assistant',
      content:   '',
      timestamp: new Date(),
      status:    'streaming',
    };

    setMessages(prev => [...prev, userMsg, assistantMsg]);
    setInput('');
    setIsLoading(true);

    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/v1/chat`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ message: content }),
      });

      if (!res.ok) throw new Error('API error');

      // Stream response
      const reader  = res.body?.getReader();
      const decoder = new TextDecoder();

      if (reader) {
        let accumulated = '';
        let citations: Citation[] = [];

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          const chunk = decoder.decode(value, { stream: true });
          const lines = chunk.split('\n').filter(l => l.startsWith('data: '));

          for (const line of lines) {
            const data = line.replace('data: ', '');
            if (data === '[DONE]') break;

            try {
              const parsed = JSON.parse(data);
              if (parsed.delta)     accumulated += parsed.delta;
              if (parsed.citations) citations = parsed.citations;

              setMessages(prev => prev.map(m =>
                m.id === assistantMsg.id
                  ? { ...m, content: accumulated, citations, status: 'streaming' }
                  : m
              ));
            } catch {}
          }
        }

        setMessages(prev => prev.map(m =>
          m.id === assistantMsg.id ? { ...m, status: 'done' } : m
        ));
      }
    } catch (err) {
      setMessages(prev => prev.map(m =>
        m.id === assistantMsg.id ? { ...m, status: 'error', content: '' } : m
      ));
    } finally {
      setIsLoading(false);
    }
  }, [input, isLoading]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <div className="flex h-full flex-col bg-neutral-50 dark:bg-neutral-950">
      {/* Messages */}
      <div className="flex-1 overflow-y-auto">
        {messages.length === 0 ? (
          <EmptyState onPromptClick={(t) => sendMessage(t)} />
        ) : (
          <div className="mx-auto max-w-3xl py-6">
            {messages.map((msg, idx) => (
              <MessageBubble
                key={msg.id}
                message={msg}
                isLast={idx === messages.length - 1}
              />
            ))}
            {isLoading && messages[messages.length - 1]?.status !== 'streaming' && (
              <TypingIndicator />
            )}
            <div ref={bottomRef} />
          </div>
        )}
      </div>

      {/* Input Area */}
      <div className="border-t border-neutral-200 dark:border-neutral-800 bg-white dark:bg-neutral-900 px-4 py-4">
        <div className="mx-auto max-w-3xl">
          <div className="relative flex items-end gap-2 rounded-2xl border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 px-4 py-3 shadow-sm focus-within:border-primary-400 dark:focus-within:border-primary-600 transition-colors duration-200">
            <textarea
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Tanyakan tentang regulasi MBG, validasi menu, atau cari supplier..."
              rows={1}
              className="flex-1 resize-none bg-transparent text-sm text-neutral-900 dark:text-neutral-100 placeholder-neutral-400 dark:placeholder-neutral-500 outline-none leading-relaxed"
              style={{ maxHeight: '160px' }}
            />
            <button
              onClick={() => sendMessage()}
              disabled={!input.trim() || isLoading}
              className={cn(
                'flex h-8 w-8 shrink-0 items-center justify-center rounded-xl transition-all duration-150',
                input.trim() && !isLoading
                  ? 'bg-primary-500 text-white hover:bg-primary-600 active:scale-90 shadow-sm shadow-primary-500/30'
                  : 'bg-neutral-100 dark:bg-neutral-700 text-neutral-400 dark:text-neutral-500 cursor-not-allowed'
              )}
            >
              {isLoading ? <StopCircle className="h-4 w-4" /> : <Send className="h-4 w-4" />}
            </button>
          </div>
          <p className="mt-2 text-center text-[11px] text-neutral-400 dark:text-neutral-600">
            MBGBrain dapat membuat kesalahan. Selalu verifikasi dengan regulasi asli.
          </p>
        </div>
      </div>
    </div>
  );
}
```

#### 1.6.3 — Menu Validator UI

```tsx
[FILE: apps/web/src/components/validator/menu-validator.tsx]
/**
 * Nutrition Menu Validator UI
 * Input: text bebas menu makanan
 * Output: analisis gizi + compliance status + rekomendasi
 */
'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChefHat, CheckCircle2, XCircle, AlertTriangle, Download, RefreshCw, Plus, X } from 'lucide-react';
import { cn } from '@/lib/utils';

// Types
type RecipientGroup = 'sd' | 'smp' | 'balita' | 'bumil';
type ComplianceStatus = 'memenuhi' | 'kurang' | 'tidak_memenuhi';

interface NutrientResult {
  name:       string;
  value:      number;
  unit:       string;
  standard:   number;
  percentage: number;
  status:     ComplianceStatus;
}

interface ValidationResult {
  status:       ComplianceStatus;
  score:        number;  // 0–100
  nutrients:    NutrientResult[];
  suggestions:  string[];
  regulation:   string;
}

const RECIPIENT_GROUPS: { value: RecipientGroup; label: string; emoji: string }[] = [
  { value: 'sd',    label: 'Siswa SD',           emoji: '🏫' },
  { value: 'smp',   label: 'Siswa SMP',          emoji: '📚' },
  { value: 'balita', label: 'Balita (2–5 th)',   emoji: '👶' },
  { value: 'bumil',  label: 'Ibu Hamil/Menyusui', emoji: '🤱' },
];

const STATUS_CONFIG = {
  memenuhi:        { label: 'Memenuhi Standar',  icon: CheckCircle2, color: 'text-primary-600',  bg: 'bg-primary-50  dark:bg-primary-900/30',  border: 'border-primary-200 dark:border-primary-800' },
  kurang:          { label: 'Kurang',            icon: AlertTriangle, color: 'text-accent-600',  bg: 'bg-accent-50   dark:bg-accent-900/30',   border: 'border-accent-200  dark:border-accent-800'  },
  tidak_memenuhi:  { label: 'Tidak Memenuhi',   icon: XCircle,       color: 'text-red-600',     bg: 'bg-red-50      dark:bg-red-900/30',      border: 'border-red-200     dark:border-red-800'     },
};

function NutrientBar({ nutrient }: { nutrient: NutrientResult }) {
  const pct = Math.min(nutrient.percentage, 150);
  const color = nutrient.status === 'memenuhi' ? 'bg-primary-500' : nutrient.status === 'kurang' ? 'bg-accent-400' : 'bg-red-500';

  return (
    <div className="space-y-1.5">
      <div className="flex items-center justify-between text-sm">
        <span className="font-medium text-neutral-700 dark:text-neutral-300">{nutrient.name}</span>
        <span className="text-neutral-500 dark:text-neutral-400 text-xs">
          {nutrient.value.toFixed(1)} / {nutrient.standard} {nutrient.unit}
          <span className="ml-2 font-semibold text-xs" style={{ color: nutrient.status === 'memenuhi' ? '#2a9d5c' : nutrient.status === 'kurang' ? '#d97706' : '#dc2626' }}>
            {nutrient.percentage.toFixed(0)}%
          </span>
        </span>
      </div>
      <div className="h-2 rounded-full bg-neutral-100 dark:bg-neutral-800 overflow-hidden">
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
  const [menuInput,  setMenuInput]  = useState('');
  const [recipient,  setRecipient]  = useState<RecipientGroup>('sd');
  const [result,     setResult]     = useState<ValidationResult | null>(null);
  const [loading,    setLoading]    = useState(false);

  const validate = async () => {
    if (!menuInput.trim()) return;
    setLoading(true);
    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/v1/validate-menu`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ menu: menuInput, recipient_group: recipient }),
      });
      const data = await res.json();
      setResult(data);
    } catch (err) {
      // handle error
    } finally {
      setLoading(false);
    }
  };

  const statusCfg = result ? STATUS_CONFIG[result.status] : null;

  return (
    <div className="mx-auto max-w-2xl p-6 space-y-6">
      {/* Header */}
      <div>
        <h1 className="font-display text-2xl font-semibold text-neutral-900 dark:text-neutral-100 flex items-center gap-2.5">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary-500">
            <ChefHat className="h-5 w-5 text-white" />
          </span>
          Validator Menu Gizi
        </h1>
        <p className="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
          Masukkan rencana menu dalam bahasa bebas. Sistem akan menganalisis nilai gizi berdasarkan standar MBG.
        </p>
      </div>

      {/* Recipient Group */}
      <div>
        <label className="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2">
          Kelompok Penerima Manfaat
        </label>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
          {RECIPIENT_GROUPS.map((g) => (
            <button
              key={g.value}
              onClick={() => setRecipient(g.value)}
              className={cn(
                'flex flex-col items-center gap-1.5 rounded-xl border px-3 py-3 text-sm transition-all duration-150',
                recipient === g.value
                  ? 'border-primary-400 dark:border-primary-600 bg-primary-50 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 shadow-sm'
                  : 'border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 text-neutral-600 dark:text-neutral-400 hover:border-neutral-300 dark:hover:border-neutral-600'
              )}
            >
              <span className="text-xl">{g.emoji}</span>
              <span className="text-xs font-medium text-center leading-tight">{g.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Menu Input */}
      <div>
        <label className="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2">
          Rencana Menu
        </label>
        <textarea
          value={menuInput}
          onChange={(e) => setMenuInput(e.target.value)}
          rows={4}
          placeholder="Contoh: nasi putih 200g, ayam goreng 75g, tempe orek 50g, sayur bayam 100g, buah pisang 1 buah..."
          className={cn(
            'w-full rounded-2xl border border-neutral-200 dark:border-neutral-700',
            'bg-white dark:bg-neutral-800 px-4 py-3',
            'text-sm text-neutral-900 dark:text-neutral-100 placeholder-neutral-400',
            'focus:outline-none focus:border-primary-400 dark:focus:border-primary-600',
            'resize-none transition-colors duration-200'
          )}
        />
      </div>

      {/* Submit */}
      <button
        onClick={validate}
        disabled={!menuInput.trim() || loading}
        className={cn(
          'w-full flex items-center justify-center gap-2 rounded-2xl py-3 text-sm font-semibold transition-all duration-150',
          menuInput.trim() && !loading
            ? 'bg-primary-500 text-white hover:bg-primary-600 active:scale-[0.98] shadow-sm shadow-primary-500/30'
            : 'bg-neutral-100 dark:bg-neutral-800 text-neutral-400 cursor-not-allowed'
        )}
      >
        {loading ? (
          <><RefreshCw className="h-4 w-4 animate-spin" /> Menganalisis...</>
        ) : (
          <><ChefHat className="h-4 w-4" /> Validasi Menu</>
        )}
      </button>

      {/* Results */}
      <AnimatePresence>
        {result && statusCfg && (
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 16 }}
            transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
            className="space-y-4"
          >
            {/* Status Banner */}
            <div className={cn('flex items-center gap-3 rounded-2xl border p-4', statusCfg.bg, statusCfg.border)}>
              <statusCfg.icon className={cn('h-6 w-6 shrink-0', statusCfg.color)} />
              <div className="flex-1">
                <p className={cn('font-semibold text-sm', statusCfg.color)}>{statusCfg.label}</p>
                <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">Berdasarkan {result.regulation}</p>
              </div>
              <div className="text-right">
                <span className={cn('text-2xl font-bold font-display', statusCfg.color)}>{result.score}</span>
                <span className="text-xs text-neutral-400">/100</span>
              </div>
            </div>

            {/* Nutrient Breakdown */}
            <div className="rounded-2xl border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800/50 p-5 space-y-4">
              <h3 className="font-semibold text-sm text-neutral-900 dark:text-neutral-100">Rincian Nilai Gizi</h3>
              {result.nutrients.map((n) => (
                <NutrientBar key={n.name} nutrient={n} />
              ))}
            </div>

            {/* Suggestions */}
            {result.suggestions.length > 0 && (
              <div className="rounded-2xl border border-accent-200 dark:border-accent-800 bg-accent-50 dark:bg-accent-900/20 p-4 space-y-2">
                <h3 className="font-semibold text-sm text-accent-700 dark:text-accent-300 flex items-center gap-1.5">
                  <AlertTriangle className="h-4 w-4" /> Rekomendasi
                </h3>
                <ul className="space-y-1.5">
                  {result.suggestions.map((s, i) => (
                    <li key={i} className="flex items-start gap-2 text-sm text-neutral-700 dark:text-neutral-300">
                      <span className="mt-1.5 h-1.5 w-1.5 rounded-full bg-accent-400 shrink-0" />
                      {s}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {/* Actions */}
            <div className="flex gap-2">
              <button className="flex-1 flex items-center justify-center gap-2 rounded-xl border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 py-2.5 text-sm font-medium text-neutral-700 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-700 transition-colors">
                <Download className="h-4 w-4" /> Unduh PDF
              </button>
              <button
                onClick={() => { setResult(null); setMenuInput(''); }}
                className="flex items-center justify-center gap-2 rounded-xl border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 px-4 py-2.5 text-sm font-medium text-neutral-500 hover:bg-neutral-50 dark:hover:bg-neutral-700 transition-colors"
              >
                <RefreshCw className="h-4 w-4" /> Reset
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
```

### 1.7 — Halaman-halaman Route

```
[AGENT ACTION] — Buat file berikut dengan konten minimal yang functional:

apps/web/src/app/(dashboard)/layout.tsx         ← Layout dengan Sidebar
apps/web/src/app/(dashboard)/chat/page.tsx      ← Mount <ChatInterface />
apps/web/src/app/(dashboard)/validator/page.tsx ← Mount <MenuValidator />
apps/web/src/app/(dashboard)/compliance/page.tsx← Compliance Checker SK 244
apps/web/src/app/(dashboard)/suppliers/page.tsx ← Direktori UMKM
apps/web/src/app/(dashboard)/history/page.tsx   ← Riwayat Query
apps/web/src/app/(dashboard)/settings/page.tsx  ← Pengaturan akun

apps/web/src/app/(auth)/login/page.tsx          ← Login dengan Supabase Auth
apps/web/src/app/(auth)/register/page.tsx       ← Registrasi
apps/web/src/app/(auth)/layout.tsx              ← Layout auth (centered)

apps/web/src/app/page.tsx                       ← Landing page (redirect ke /chat jika logged in)
apps/web/src/app/api/auth/callback/route.ts     ← Supabase OAuth callback
```

```tsx
[FILE: apps/web/src/app/(dashboard)/layout.tsx]
import { Sidebar } from '@/components/layout/sidebar';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-screen overflow-hidden bg-neutral-50 dark:bg-neutral-950">
      <Sidebar />
      <main className="flex-1 overflow-hidden">
        {children}
      </main>
    </div>
  );
}
```

### 1.8 — Komponen Landing Page

```tsx
[FILE: apps/web/src/app/page.tsx]
/**
 * Landing page MBGBrain
 * Desain: hijau organik, modern, meyakinkan
 * Sections: Hero → Features → Pricing → CTA
 */
// [AGENT ACTION] Implement full landing page dengan:
// - Hero section: tagline + CTA + mockup screenshot
// - Feature cards: 4 modul utama (chat, validator, compliance, supplier)
// - Pricing section: 4 tier dari PRD.md
// - Social proof: testimonial SPPG pilot
// - Footer dengan link dokumentasi
```

[VERIFY] Sebelum lanjut ke Fase 2:
- [ ] `pnpm dev` berjalan tanpa error di apps/web
- [ ] Route /chat, /validator, /compliance, /suppliers dapat diakses
- [ ] Dark mode toggle berfungsi
- [ ] Sidebar collapse/expand berfungsi
- [ ] Chat interface menampilkan empty state dengan quick prompts
- [ ] Font Plus Jakarta Sans dan DM Sans ter-load dengan benar

---

## Fase 2 — Supabase Setup & Database (Hari 5–7)

### 2.1 — Struktur Direktori Supabase

```
supabase/
├── config.toml
├── migrations/
│   ├── 00001_initial_schema.sql
│   ├── 00002_vector_extension.sql
│   ├── 00003_knowledge_base.sql
│   ├── 00004_supplier_directory.sql
│   ├── 00005_rls_policies.sql
│   └── 00006_seed_data.sql
├── seed/
│   ├── regulations.sql     ← data regulasi MBG awal
│   └── food_database.sql   ← subset TKPI (Tabel Komposisi Pangan Indonesia)
└── functions/
    └── match_documents/    ← Edge Function untuk similarity search
```

### 2.2 — Inisialisasi Supabase CLI

```bash
[AGENT ACTION]
npm install -g supabase
supabase init
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

### 2.3 — Migration: Initial Schema

```sql
[FILE: supabase/migrations/00001_initial_schema.sql]
-- ─── Extensions ──────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";   -- full-text search Indonesia
CREATE EXTENSION IF NOT EXISTS "unaccent";  -- normalize aksen huruf
CREATE EXTENSION IF NOT EXISTS "postgis";   -- geospatial untuk matching lokasi

-- ─── Enums ───────────────────────────────────────────────────────────────────
CREATE TYPE user_role      AS ENUM ('sppg_admin', 'umkm', 'dinas', 'public', 'api_user', 'superadmin');
CREATE TYPE org_type       AS ENUM ('sppg', 'umkm', 'dinas', 'other');
CREATE TYPE compliance_status AS ENUM ('memenuhi', 'kurang', 'tidak_memenuhi');

-- ─── Organizations ────────────────────────────────────────────────────────────
CREATE TABLE organizations (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  type          org_type NOT NULL,
  province      TEXT,
  city          TEXT,
  district      TEXT,
  village       TEXT,
  address       TEXT,
  phone         TEXT,
  npwp          TEXT UNIQUE,
  verified_at   TIMESTAMPTZ,
  verified_by   UUID,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  metadata      JSONB DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Users ────────────────────────────────────────────────────────────────────
CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT,
  avatar_url    TEXT,
  role          user_role NOT NULL DEFAULT 'public',
  org_id        UUID REFERENCES organizations(id),
  onboarded_at  TIMESTAMPTZ,
  preferences   JSONB DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── API Keys ─────────────────────────────────────────────────────────────────
CREATE TABLE api_keys (
  id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id              UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name                 TEXT NOT NULL,
  key_hash             TEXT NOT NULL UNIQUE,  -- bcrypt hash, never store plaintext
  key_prefix           TEXT NOT NULL,         -- e.g. "mbg_live_xxxxx" untuk display
  rate_limit_per_min   INTEGER NOT NULL DEFAULT 100,
  monthly_limit        INTEGER,               -- NULL = unlimited
  total_calls          BIGINT NOT NULL DEFAULT 0,
  last_used_at         TIMESTAMPTZ,
  is_active            BOOLEAN NOT NULL DEFAULT true,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at           TIMESTAMPTZ
);

-- ─── Query Logs ───────────────────────────────────────────────────────────────
CREATE TABLE query_logs (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID REFERENCES profiles(id),
  api_key_id        UUID REFERENCES api_keys(id),
  module            TEXT NOT NULL,  -- 'chat' | 'validate_menu' | 'compliance' | 'supplier_search'
  query_text        TEXT,
  response_time_ms  INTEGER,
  tokens_used       INTEGER,
  cache_hit         BOOLEAN DEFAULT false,
  rating            SMALLINT CHECK (rating IN (1, -1)),  -- thumbs up/down
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Partisi per bulan (untuk performa query analytics)
CREATE TABLE query_logs_2026_05 PARTITION OF query_logs
  FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE query_logs_2026_06 PARTITION OF query_logs
  FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

-- ─── Menu Validations ─────────────────────────────────────────────────────────
CREATE TABLE menu_validations (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID REFERENCES profiles(id),
  org_id              UUID REFERENCES organizations(id),
  menu_input          TEXT NOT NULL,
  recipient_group     TEXT NOT NULL,  -- 'sd' | 'smp' | 'balita' | 'bumil'
  analysis_result     JSONB NOT NULL,
  compliance_status   compliance_status,
  score               SMALLINT,
  regulation_version  TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Compliance Checks ────────────────────────────────────────────────────────
CREATE TABLE compliance_checks (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID REFERENCES profiles(id),
  org_id              UUID REFERENCES organizations(id),
  check_type          TEXT NOT NULL,  -- 'sk244_supplier' | 'sk244_menu' | 'bpom'
  inputs              JSONB NOT NULL,
  result              JSONB NOT NULL,
  overall_status      compliance_status,
  report_url          TEXT,  -- URL ke PDF laporan di Supabase Storage
  regulation_version  TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Indexes ──────────────────────────────────────────────────────────────────
CREATE INDEX idx_profiles_org_id     ON profiles(org_id);
CREATE INDEX idx_api_keys_user_id    ON api_keys(user_id);
CREATE INDEX idx_api_keys_key_hash   ON api_keys(key_hash);
CREATE INDEX idx_query_logs_user_id  ON query_logs(user_id);
CREATE INDEX idx_query_logs_created  ON query_logs(created_at DESC);
CREATE INDEX idx_menu_val_org_id     ON menu_validations(org_id);
CREATE INDEX idx_compliance_org_id   ON compliance_checks(org_id);

-- ─── Triggers ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated     BEFORE UPDATE ON profiles     FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_organizations_updated BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### 2.4 — Migration: Vector Extension & Knowledge Base

```sql
[FILE: supabase/migrations/00002_vector_extension.sql]
CREATE EXTENSION IF NOT EXISTS vector;

[FILE: supabase/migrations/00003_knowledge_base.sql]

-- ─── Regulation Documents ─────────────────────────────────────────────────────
CREATE TABLE regulation_documents (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title            TEXT NOT NULL,
  short_code       TEXT NOT NULL UNIQUE,  -- e.g. 'SK_244_2025', 'PERPRES_83_2024'
  type             TEXT NOT NULL,         -- 'sk' | 'perpres' | 'permen' | 'pedoman'
  issuer           TEXT NOT NULL,         -- 'BGN' | 'Kemenkes' | 'BPOM' | 'Kemensetneg'
  effective_date   DATE NOT NULL,
  version          TEXT NOT NULL DEFAULT '1.0',
  is_superseded    BOOLEAN NOT NULL DEFAULT false,
  superseded_by_id UUID REFERENCES regulation_documents(id),
  source_url       TEXT,
  storage_path     TEXT,   -- path di Supabase Storage
  full_text        TEXT,
  summary          TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Knowledge Chunks (RAG) ───────────────────────────────────────────────────
CREATE TABLE knowledge_chunks (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  doc_id        UUID NOT NULL REFERENCES regulation_documents(id) ON DELETE CASCADE,
  chunk_index   INTEGER NOT NULL,
  chunk_text    TEXT NOT NULL,
  -- Embedding vector 1536 dimensi (OpenAI text-embedding-3-small)
  embedding     vector(1536),
  -- Metadata untuk filtering dan re-ranking
  metadata      JSONB DEFAULT '{}',
  -- Untuk hybrid search: full-text search vector
  fts_vector    tsvector GENERATED ALWAYS AS (
    to_tsvector('indonesian', chunk_text)
  ) STORED,
  token_count   INTEGER,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Indexes untuk vector similarity search ───────────────────────────────────
-- IVFFlat index: lebih cepat untuk production (vs HNSW yang lebih akurat tapi RAM lebih besar)
CREATE INDEX idx_knowledge_chunks_embedding
  ON knowledge_chunks USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

-- Full-text search index
CREATE INDEX idx_knowledge_chunks_fts
  ON knowledge_chunks USING gin (fts_vector);

-- Filter by doc
CREATE INDEX idx_knowledge_chunks_doc_id ON knowledge_chunks(doc_id);

-- ─── Query Cache (mengurangi biaya LLM) ──────────────────────────────────────
CREATE TABLE query_cache (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  query_hash      TEXT NOT NULL UNIQUE,  -- SHA256 dari normalized query
  query_text      TEXT NOT NULL,
  response_text   TEXT NOT NULL,
  citations       JSONB DEFAULT '[]',
  module          TEXT NOT NULL,
  hit_count       INTEGER NOT NULL DEFAULT 1,
  last_hit_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days')
);

CREATE INDEX idx_query_cache_hash    ON query_cache(query_hash);
CREATE INDEX idx_query_cache_expires ON query_cache(expires_at);

-- Auto-cleanup expired cache
CREATE OR REPLACE FUNCTION cleanup_expired_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM query_cache WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- ─── Food Database (TKPI) ─────────────────────────────────────────────────────
CREATE TABLE food_items (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  kode_pangan       TEXT UNIQUE,         -- kode TKPI
  nama_pangan       TEXT NOT NULL,
  nama_alias        TEXT[],              -- sinonim (ayam goreng, ayam bakar, dll)
  kategori          TEXT NOT NULL,       -- 'serealia' | 'daging' | 'sayuran' | 'buah' | dll
  -- Nilai gizi per 100g
  energi_kkal       DECIMAL(8,2),
  protein_g         DECIMAL(8,2),
  lemak_g           DECIMAL(8,2),
  karbohidrat_g     DECIMAL(8,2),
  serat_g           DECIMAL(8,2),
  kalsium_mg        DECIMAL(8,2),
  zat_besi_mg       DECIMAL(8,2),
  vitamin_c_mg      DECIMAL(8,2),
  vitamin_a_mcg     DECIMAL(8,2),
  -- FTS untuk matching nama makanan
  fts_vector        tsvector GENERATED ALWAYS AS (
    to_tsvector('indonesian', nama_pangan || ' ' || COALESCE(array_to_string(nama_alias, ' '), ''))
  ) STORED,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_food_items_fts ON food_items USING gin(fts_vector);
CREATE INDEX idx_food_items_nama ON food_items USING gin(nama_pangan gin_trgm_ops);

-- ─── Nutrition Standards per Group ────────────────────────────────────────────
CREATE TABLE nutrition_standards (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_group  TEXT NOT NULL,  -- 'sd' | 'smp' | 'balita' | 'bumil'
  energi_min_kkal  DECIMAL(8,2),
  energi_max_kkal  DECIMAL(8,2),
  protein_min_g    DECIMAL(8,2),
  lemak_min_g      DECIMAL(8,2),
  karbohidrat_min_g DECIMAL(8,2),
  regulation_ref   TEXT,  -- referensi regulasi
  effective_date   DATE NOT NULL,
  is_current       BOOLEAN NOT NULL DEFAULT true
);
```

### 2.5 — Migration: Supplier Directory

```sql
[FILE: supabase/migrations/00004_supplier_directory.sql]

-- ─── Suppliers ────────────────────────────────────────────────────────────────
CREATE TABLE suppliers (
  id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id                    UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  -- Produk & Kapasitas
  product_categories        TEXT[] NOT NULL DEFAULT '{}',
  product_details           JSONB DEFAULT '[]',   -- [{name, unit, price_per_unit}]
  daily_capacity_servings   INTEGER,
  min_order_servings        INTEGER,
  -- Lokasi (PostGIS)
  location                  geography(POINT, 4326),
  service_radius_km         INTEGER DEFAULT 20,
  -- Status
  is_verified               BOOLEAN NOT NULL DEFAULT false,
  verified_by               UUID REFERENCES profiles(id),
  verified_at               TIMESTAMPTZ,
  is_active                 BOOLEAN NOT NULL DEFAULT true,
  -- Profile completeness (0–100)
  profile_completeness_pct  SMALLINT NOT NULL DEFAULT 0,
  -- SK 244 compliance
  sk244_compliant           BOOLEAN,
  sk244_checked_at          TIMESTAMPTZ,
  -- Metrics
  total_orders_fulfilled    INTEGER DEFAULT 0,
  avg_rating                DECIMAL(3,2),
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Supplier Documents ───────────────────────────────────────────────────────
CREATE TABLE supplier_documents (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supplier_id   UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
  doc_type      TEXT NOT NULL,    -- 'nib' | 'sertifikat_halal' | 'sertifikat_bpom' | 'foto_dapur' | dll
  doc_name      TEXT NOT NULL,
  file_url      TEXT NOT NULL,    -- Supabase Storage URL
  file_size     INTEGER,
  verified_at   TIMESTAMPTZ,
  expires_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── SPPG-Supplier Matches ────────────────────────────────────────────────────
CREATE TABLE sppg_supplier_matches (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sppg_org_id   UUID NOT NULL REFERENCES organizations(id),
  supplier_id   UUID NOT NULL REFERENCES suppliers(id),
  status        TEXT NOT NULL DEFAULT 'candidate',  -- 'candidate' | 'active' | 'inactive'
  match_score   DECIMAL(4,2),   -- similarity score dari matching algorithm
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(sppg_org_id, supplier_id)
);

-- ─── Geospatial Indexes ───────────────────────────────────────────────────────
CREATE INDEX idx_suppliers_location ON suppliers USING gist(location);
CREATE INDEX idx_suppliers_categories ON suppliers USING gin(product_categories);
CREATE INDEX idx_suppliers_org_id ON suppliers(org_id);

-- ─── Function: Find Nearby Suppliers ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION find_nearby_suppliers(
  sppg_lat    DOUBLE PRECISION,
  sppg_lon    DOUBLE PRECISION,
  radius_km   INTEGER DEFAULT 20,
  category    TEXT DEFAULT NULL,
  min_cap     INTEGER DEFAULT NULL
)
RETURNS TABLE (
  supplier_id UUID,
  org_name    TEXT,
  distance_km DECIMAL,
  categories  TEXT[],
  capacity    INTEGER,
  is_verified BOOLEAN,
  score       DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.id,
    o.name,
    ROUND((ST_Distance(s.location, ST_MakePoint(sppg_lon, sppg_lat)::geography) / 1000)::DECIMAL, 2),
    s.product_categories,
    s.daily_capacity_servings,
    s.is_verified,
    s.profile_completeness_pct::DECIMAL / 100
  FROM suppliers s
  JOIN organizations o ON o.id = s.org_id
  WHERE
    s.is_active = true
    AND ST_DWithin(s.location, ST_MakePoint(sppg_lon, sppg_lat)::geography, radius_km * 1000)
    AND (category IS NULL OR category = ANY(s.product_categories))
    AND (min_cap IS NULL OR s.daily_capacity_servings >= min_cap)
  ORDER BY ST_Distance(s.location, ST_MakePoint(sppg_lon, sppg_lat)::geography);
END;
$$ LANGUAGE plpgsql;
```

### 2.6 — Row Level Security (RLS)

```sql
[FILE: supabase/migrations/00005_rls_policies.sql]

-- Enable RLS
ALTER TABLE profiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations         ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_keys              ENABLE ROW LEVEL SECURITY;
ALTER TABLE query_logs            ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_validations      ENABLE ROW LEVEL SECURITY;
ALTER TABLE compliance_checks     ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers             ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_documents    ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_chunks      ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_items            ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_standards   ENABLE ROW LEVEL SECURITY;

-- Helper function
CREATE OR REPLACE FUNCTION auth_user_id() RETURNS UUID AS $$
  SELECT auth.uid();
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth_user_role() RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ─── Profiles ────────────────────────────────────────────────────────────────
CREATE POLICY "Profiles: user can read own" ON profiles
  FOR SELECT USING (id = auth_user_id());
CREATE POLICY "Profiles: user can update own" ON profiles
  FOR UPDATE USING (id = auth_user_id());
CREATE POLICY "Profiles: insert on signup" ON profiles
  FOR INSERT WITH CHECK (id = auth_user_id());

-- ─── API Keys ─────────────────────────────────────────────────────────────────
CREATE POLICY "API Keys: user manages own" ON api_keys
  FOR ALL USING (user_id = auth_user_id());

-- ─── Query Logs ───────────────────────────────────────────────────────────────
CREATE POLICY "Query Logs: user reads own" ON query_logs
  FOR SELECT USING (user_id = auth_user_id());

-- ─── Menu Validations ─────────────────────────────────────────────────────────
CREATE POLICY "Menu Val: user reads own" ON menu_validations
  FOR SELECT USING (user_id = auth_user_id());
CREATE POLICY "Menu Val: user inserts own" ON menu_validations
  FOR INSERT WITH CHECK (user_id = auth_user_id());

-- ─── Compliance Checks ────────────────────────────────────────────────────────
CREATE POLICY "Compliance: user reads own" ON compliance_checks
  FOR SELECT USING (user_id = auth_user_id());

-- ─── Suppliers: public read, owner write ──────────────────────────────────────
CREATE POLICY "Suppliers: public read active" ON suppliers
  FOR SELECT USING (is_active = true);
CREATE POLICY "Suppliers: owner manages" ON suppliers
  FOR ALL USING (
    org_id IN (SELECT org_id FROM profiles WHERE id = auth_user_id())
  );

-- ─── Knowledge Base: public read ──────────────────────────────────────────────
CREATE POLICY "Knowledge: public read" ON knowledge_chunks  FOR SELECT USING (true);
CREATE POLICY "Food: public read"      ON food_items        FOR SELECT USING (true);
CREATE POLICY "Standards: public read" ON nutrition_standards FOR SELECT USING (true);
```

### 2.7 — Supabase Edge Function: Similarity Search

```typescript
[FILE: supabase/functions/match_documents/index.ts]
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { query_embedding, match_count = 5, filter } = await req.json();

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Hybrid search: vector similarity + full-text search
    const { data: vectorResults, error: vectorError } = await supabaseClient.rpc(
      'match_knowledge_chunks',
      {
        query_embedding,
        match_threshold: 0.7,
        match_count:     match_count + 5,  // over-fetch for re-ranking
        filter:          filter ?? {},
      }
    );

    if (vectorError) throw vectorError;

    // Re-rank by recency (newer regulations weighted higher)
    const reranked = (vectorResults ?? [])
      .sort((a: any, b: any) => {
        const recencyWeight = 0.2;
        const simWeight = 0.8;
        const scoreA = simWeight * a.similarity + recencyWeight * (a.is_current_regulation ? 1 : 0.5);
        const scoreB = simWeight * b.similarity + recencyWeight * (b.is_current_regulation ? 1 : 0.5);
        return scoreB - scoreA;
      })
      .slice(0, match_count);

    return new Response(JSON.stringify(reranked), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
```

```sql
-- SQL function untuk match_knowledge_chunks (jalankan di Supabase SQL Editor)
CREATE OR REPLACE FUNCTION match_knowledge_chunks(
  query_embedding vector(1536),
  match_threshold FLOAT DEFAULT 0.7,
  match_count     INT   DEFAULT 5,
  filter          JSONB DEFAULT '{}'
)
RETURNS TABLE (
  id               UUID,
  doc_id           UUID,
  chunk_text       TEXT,
  similarity       FLOAT,
  metadata         JSONB,
  regulation_code  TEXT,
  effective_date   DATE,
  is_current_regulation BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    kc.id,
    kc.doc_id,
    kc.chunk_text,
    1 - (kc.embedding <=> query_embedding) AS similarity,
    kc.metadata,
    rd.short_code,
    rd.effective_date,
    NOT rd.is_superseded AS is_current_regulation
  FROM knowledge_chunks kc
  JOIN regulation_documents rd ON rd.id = kc.doc_id
  WHERE
    1 - (kc.embedding <=> query_embedding) > match_threshold
    AND (filter->>'doc_type' IS NULL OR rd.type = filter->>'doc_type')
    AND rd.is_superseded = false  -- default: hanya regulasi aktif
  ORDER BY kc.embedding <=> query_embedding
  LIMIT match_count * 2;  -- over-fetch untuk re-ranking di Edge Function
END;
$$ LANGUAGE plpgsql;
```

[VERIFY] Sebelum lanjut ke Fase 3:
- [ ] `supabase db push` berhasil tanpa error
- [ ] Semua tabel terbuat di Supabase Dashboard
- [ ] RLS policies aktif
- [ ] pgvector extension enabled
- [ ] PostGIS extension enabled
- [ ] Edge Function `match_documents` ter-deploy

---

## Fase 3 — FastAPI Backend (Hari 8–18)

### 3.1 — Struktur Direktori Backend

```
apps/api/
├── main.py                    ← FastAPI app entry point
├── pyproject.toml             ← dependency management (uv/poetry)
├── Dockerfile
├── .env                       ← copy dari root .env.example
│
├── app/
│   ├── __init__.py
│   ├── config.py              ← settings via pydantic-settings
│   ├── dependencies.py        ← FastAPI dependencies (auth, db, rate limit)
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   ├── router.py          ← mount semua routers
│   │   └── v1/
│   │       ├── chat.py        ← POST /api/v1/chat (SSE streaming)
│   │       ├── validate_menu.py ← POST /api/v1/validate-menu
│   │       ├── compliance.py  ← POST /api/v1/compliance-check
│   │       ├── suppliers.py   ← GET  /api/v1/suppliers/search
│   │       ├── regulations.py ← GET  /api/v1/regulations/latest
│   │       └── auth.py        ← webhook Supabase auth
│   │
│   ├── services/
│   │   ├── rag/
│   │   │   ├── pipeline.py    ← RAG orchestrator utama
│   │   │   ├── embedder.py    ← OpenAI embedding
│   │   │   ├── retriever.py   ← pgvector similarity search
│   │   │   ├── generator.py   ← Claude API call
│   │   │   └── cache.py       ← query caching
│   │   ├── nutrition/
│   │   │   ├── calculator.py  ← hitung nilai gizi dari TKPI
│   │   │   ├── validator.py   ← bandingkan vs standar MBG
│   │   │   └── parser.py      ← parse input menu bebas → structured
│   │   ├── compliance/
│   │   │   └── sk244.py       ← rules engine SK 244
│   │   └── supplier/
│   │       └── matcher.py     ← geospatial matching
│   │
│   ├── models/
│   │   ├── chat.py            ← Pydantic schemas untuk chat
│   │   ├── nutrition.py       ← schemas nutrition validator
│   │   ├── compliance.py      ← schemas compliance checker
│   │   └── supplier.py        ← schemas supplier
│   │
│   └── core/
│       ├── auth.py            ← Supabase JWT validation
│       ├── rate_limiter.py    ← token bucket per API key
│       ├── logger.py          ← structured logging
│       └── exceptions.py      ← custom exception handlers
│
├── scripts/
│   └── ingest/
│       ├── ingest_regulations.py  ← PDF → chunks → embeddings → pgvector
│       ├── ingest_tkpi.py         ← Excel TKPI → food_items table
│       └── eval_rag.py            ← evaluasi akurasi 50 soal domain
```

### 3.2 — Dependencies

```toml
[FILE: apps/api/pyproject.toml]
[project]
name = "mbgbrain-api"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
  # Web framework
  "fastapi>=0.111.0",
  "uvicorn[standard]>=0.29.0",
  "python-multipart>=0.0.9",
  # LLM
  "anthropic>=0.26.0",
  "openai>=1.30.0",
  # Database
  "supabase>=2.4.0",
  "asyncpg>=0.29.0",
  "sqlalchemy[asyncio]>=2.0.30",
  # AI / Data
  "numpy>=1.26.0",
  "pydantic>=2.7.0",
  "pydantic-settings>=2.2.0",
  # Document processing
  "pdfplumber>=0.11.0",
  "pymupdf>=1.24.0",
  "openpyxl>=3.1.0",
  # Utilities
  "python-jose[cryptography]>=3.3.0",
  "httpx>=0.27.0",
  "structlog>=24.1.0",
  "sentry-sdk[fastapi]>=2.3.0",
  "redis>=5.0.4",        # opsional: untuk rate limiting
  "python-dotenv>=1.0.0",
  # PDF generation
  "reportlab>=4.2.0",
  "weasyprint>=61.0",
]

[tool.uv]
dev-dependencies = [
  "pytest>=8.2.0",
  "pytest-asyncio>=0.23.0",
  "httpx>=0.27.0",
  "pytest-cov>=5.0.0",
]
```

### 3.3 — App Config

```python
[FILE: apps/api/app/config.py]
from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache

class Settings(BaseSettings):
  model_config = SettingsConfigDict(env_file='.env', extra='ignore')

  # App
  APP_NAME:     str = "MBGBrain API"
  APP_VERSION:  str = "0.1.0"
  DEBUG:        bool = False
  ENVIRONMENT:  str = "production"

  # Supabase
  SUPABASE_URL:              str
  SUPABASE_SERVICE_ROLE_KEY: str
  SUPABASE_DB_URL:           str

  # LLM
  ANTHROPIC_API_KEY: str
  OPENAI_API_KEY:    str

  # Claude model — gunakan claude-sonnet-4-20250514
  CLAUDE_MODEL:      str = "claude-sonnet-4-20250514"
  CLAUDE_TEMP:       float = 0.2
  CLAUDE_MAX_TOKENS: int = 2048

  # OpenAI embedding
  EMBED_MODEL:   str = "text-embedding-3-small"
  EMBED_DIM:     int = 1536

  # RAG config
  RAG_TOP_K:           int   = 5
  RAG_THRESHOLD:       float = 0.72
  RAG_CHUNK_SIZE:      int   = 512
  RAG_CHUNK_OVERLAP:   int   = 64

  # Rate limits
  DEFAULT_RATE_LIMIT_PER_MIN: int = 100
  FREE_TIER_MONTHLY_QUERIES:  int = 50

  # Sentry
  SENTRY_DSN: str = ""

@lru_cache
def get_settings() -> Settings:
  return Settings()

settings = get_settings()
```

### 3.4 — Main FastAPI App

```python
[FILE: apps/api/main.py]
import structlog
import sentry_sdk
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

from app.config import settings
from app.api.router import api_router
from app.core.exceptions import MBGBrainException

log = structlog.get_logger()

if settings.SENTRY_DSN:
  sentry_sdk.init(
    dsn=settings.SENTRY_DSN,
    environment=settings.ENVIRONMENT,
    traces_sample_rate=0.1,
  )

@asynccontextmanager
async def lifespan(app: FastAPI):
  log.info("MBGBrain API starting", version=settings.APP_VERSION)
  yield
  log.info("MBGBrain API shutting down")

app = FastAPI(
  title=settings.APP_NAME,
  version=settings.APP_VERSION,
  description="AI Intelligence Infrastructure untuk program Makan Bergizi Gratis Indonesia",
  docs_url="/docs",
  redoc_url="/redoc",
  openapi_url="/openapi.json",
  lifespan=lifespan,
)

# ─── Middleware ────────────────────────────────────────────────────────────────
app.add_middleware(
  CORSMiddleware,
  allow_origins=[
    "http://localhost:3000",
    "https://mbgbrain.id",
    "https://*.mbgbrain.id",
  ],
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
  expose_headers=["X-Regulation-Version", "X-Cache-Hit", "X-Request-Id"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)

# ─── Exception Handlers ────────────────────────────────────────────────────────
@app.exception_handler(MBGBrainException)
async def mbgbrain_exception_handler(req: Request, exc: MBGBrainException):
  return JSONResponse(
    status_code=exc.status_code,
    content={"error": exc.message, "code": exc.code},
  )

# ─── Routes ───────────────────────────────────────────────────────────────────
app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
async def health():
  return {"status": "ok", "version": settings.APP_VERSION}
```

### 3.5 — RAG Pipeline (Inti Sistem)

```python
[FILE: apps/api/app/services/rag/pipeline.py]
"""
RAG Pipeline Utama MBGBrain
Flow: query → embed → retrieve → rerank → generate → cache
"""
import hashlib
import json
import structlog
from typing import AsyncGenerator
from anthropic import AsyncAnthropic

from app.config import settings
from app.services.rag.embedder  import embed_query
from app.services.rag.retriever import retrieve_chunks
from app.services.rag.cache     import get_cached, set_cached

log = structlog.get_logger()

SYSTEM_PROMPT = """Kamu adalah MBGBrain, asisten AI khusus untuk program Makan Bergizi Gratis (MBG) Indonesia.

PERAN:
- Menjawab pertanyaan tentang regulasi, prosedur, dan panduan operasional MBG
- Membantu SPPG, UMKM, dan pemangku kepentingan program MBG
- Memberikan informasi akurat berdasarkan dokumen regulasi resmi

ATURAN:
1. Jawab HANYA berdasarkan konteks regulasi yang diberikan
2. Selalu sertakan referensi spesifik (nama regulasi, nomor pasal)
3. Gunakan bahasa Indonesia yang jelas dan mudah dipahami
4. Jika tidak tahu, katakan "Informasi ini belum tersedia di database saya" - JANGAN mengarang
5. Posisikan dirimu sebagai "asisten", bukan pengganti konsultan hukum resmi
6. Berikan disclaimer jika pertanyaan menyentuh interpretasi hukum yang kompleks

FORMAT JAWABAN:
- Mulai dengan jawaban langsung dan ringkas
- Gunakan bullet points untuk daftar persyaratan
- Akhiri dengan referensi regulasi dalam format: [Sumber: Nama Regulasi, Pasal X]
- Maksimal 400 kata kecuali pertanyaan membutuhkan detail lebih
"""

async def run_rag_pipeline(
  query:   str,
  module:  str = "chat",
  stream:  bool = True,
) -> AsyncGenerator[str, None]:
  """
  Eksekusi RAG pipeline dengan streaming SSE output.
  Yield format: Server-Sent Events (data: {...}\n\n)
  """
  # 1. Check cache
  cache_key = hashlib.sha256(f"{module}:{query.lower().strip()}".encode()).hexdigest()
  cached = await get_cached(cache_key)

  if cached:
    log.info("Cache hit", key=cache_key[:8])
    yield f"data: {json.dumps({'delta': cached['response'], 'citations': cached['citations'], 'cached': True})}\n\n"
    yield "data: [DONE]\n\n"
    return

  # 2. Embed query
  query_embedding = await embed_query(query)

  # 3. Retrieve relevant chunks
  chunks = await retrieve_chunks(query_embedding, top_k=settings.RAG_TOP_K)

  if not chunks:
    yield f"data: {json.dumps({'delta': 'Maaf, tidak ditemukan informasi yang relevan dalam database regulasi MBG. Coba reformulasikan pertanyaan Anda.'})}\n\n"
    yield "data: [DONE]\n\n"
    return

  # 4. Build context
  context_parts = []
  citations = []

  for i, chunk in enumerate(chunks):
    context_parts.append(f"[Dokumen {i+1}] {chunk['regulation_code']}\n{chunk['chunk_text']}")
    citations.append({
      "regulation": chunk['regulation_code'],
      "article":    chunk.get('metadata', {}).get('article', ''),
      "excerpt":    chunk['chunk_text'][:200] + "...",
    })

  context = "\n\n---\n\n".join(context_parts)
  prompt  = f"KONTEKS REGULASI:\n{context}\n\nPERTANYAAN: {query}"

  # 5. Generate dengan Claude (streaming)
  client   = AsyncAnthropic(api_key=settings.ANTHROPIC_API_KEY)
  full_response = ""

  # Kirim citations dulu
  yield f"data: {json.dumps({'citations': citations})}\n\n"

  async with client.messages.stream(
    model=settings.CLAUDE_MODEL,
    max_tokens=settings.CLAUDE_MAX_TOKENS,
    temperature=settings.CLAUDE_TEMP,
    system=SYSTEM_PROMPT,
    messages=[{"role": "user", "content": prompt}],
  ) as stream:
    async for text in stream.text_stream:
      full_response += text
      yield f"data: {json.dumps({'delta': text})}\n\n"

  yield "data: [DONE]\n\n"

  # 6. Cache response (async, non-blocking)
  await set_cached(cache_key, {
    "response":  full_response,
    "citations": citations,
  })

  log.info("RAG pipeline complete", query_len=len(query), chunks=len(chunks), response_len=len(full_response))
```

### 3.6 — Chat Endpoint (SSE Streaming)

```python
[FILE: apps/api/app/api/v1/chat.py]
from fastapi import APIRouter, Depends, Request
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
import structlog

from app.services.rag.pipeline import run_rag_pipeline
from app.core.auth import get_current_user
from app.core.rate_limiter import check_rate_limit
from app.dependencies import get_supabase

log = structlog.get_logger()
router = APIRouter(tags=["Chat"])

class ChatRequest(BaseModel):
  message:     str = Field(..., min_length=3, max_length=2000)
  session_id:  str | None = None
  language:    str = "id"

@router.post("/chat")
async def chat(
  req:      ChatRequest,
  request:  Request,
  user:     dict = Depends(get_current_user),
  supabase       = Depends(get_supabase),
):
  """
  Chat dengan MBG Regulatory Assistant.
  Response di-stream sebagai Server-Sent Events (SSE).

  Headers response:
  - X-Regulation-Version: versi regulasi yang digunakan
  - X-Cache-Hit: true jika response dari cache
  """
  await check_rate_limit(user["id"])

  log.info("Chat request", user_id=user["id"][:8], query_len=len(req.message))

  # Log ke database (async, non-blocking)
  await supabase.table("query_logs").insert({
    "user_id":   user["id"],
    "module":    "chat",
    "query_text": req.message,
  }).execute()

  return StreamingResponse(
    run_rag_pipeline(req.message, module="chat"),
    media_type="text/event-stream",
    headers={
      "Cache-Control":          "no-cache",
      "X-Accel-Buffering":      "no",
      "X-Regulation-Version":   "2025-05",
    },
  )
```

### 3.7 — Nutrition Validator Service

```python
[FILE: apps/api/app/services/nutrition/calculator.py]
"""
Nutrition Calculator berdasarkan TKPI (Tabel Komposisi Pangan Indonesia)
"""
import re
import structlog
from typing import Any
from app.dependencies import get_supabase

log = structlog.get_logger()

# Standar gizi MBG per kelompok (akan diambil dari DB, ini fallback)
NUTRITION_STANDARDS = {
  "sd": {
    "energi_kkal": (400, 600),
    "protein_g":   (15, None),
    "lemak_g":     (10, None),
    "karbohidrat_g": (60, None),
  },
  "smp": {
    "energi_kkal": (500, 700),
    "protein_g":   (18, None),
    "lemak_g":     (13, None),
    "karbohidrat_g": (75, None),
  },
  "balita": {
    "energi_kkal": (350, 500),
    "protein_g":   (13, None),
    "lemak_g":     (10, None),
    "karbohidrat_g": (55, None),
  },
  "bumil": {
    "energi_kkal": (600, 800),
    "protein_g":   (25, None),
    "lemak_g":     (15, None),
    "karbohidrat_g": (85, None),
  },
}

async def parse_menu_with_ai(menu_text: str) -> list[dict]:
  """
  Gunakan Claude untuk parse teks menu bebas ke struktur terstandar.
  Output: [{food_name: str, amount_g: float}, ...]
  """
  from anthropic import AsyncAnthropic
  from app.config import settings
  import json

  client = AsyncAnthropic(api_key=settings.ANTHROPIC_API_KEY)

  prompt = f"""Parse menu makanan berikut ke format JSON terstruktur.
Untuk setiap item makanan, ekstrak nama dan estimasi berat dalam gram.
Jika berat tidak disebutkan, gunakan porsi standar Indonesia.

Menu: {menu_text}

Respond ONLY dengan JSON array, tidak ada teks lain:
[{{"food_name": "nasi putih", "amount_g": 200}}, ...]"""

  msg = await client.messages.create(
    model=settings.CLAUDE_MODEL,
    max_tokens=500,
    temperature=0,
    messages=[{"role": "user", "content": prompt}],
  )

  try:
    return json.loads(msg.content[0].text)
  except Exception:
    return []

async def lookup_nutrition(food_name: str, amount_g: float, supabase) -> dict | None:
  """Cari nilai gizi di database TKPI."""
  result = await supabase.rpc(
    "search_food_by_name",
    {"query": food_name, "limit_n": 1},
  ).execute()

  if not result.data:
    return None

  food = result.data[0]
  ratio = amount_g / 100  # nilai gizi per 100g

  return {
    "food_name":     food["nama_pangan"],
    "amount_g":      amount_g,
    "energi_kkal":   round((food["energi_kkal"] or 0) * ratio, 1),
    "protein_g":     round((food["protein_g"]   or 0) * ratio, 1),
    "lemak_g":       round((food["lemak_g"]     or 0) * ratio, 1),
    "karbohidrat_g": round((food["karbohidrat_g"] or 0) * ratio, 1),
    "serat_g":       round((food["serat_g"]     or 0) * ratio, 1),
  }

async def validate_menu(menu_text: str, recipient_group: str) -> dict:
  """Main function: parse menu → lookup gizi → validasi vs standar."""
  from app.dependencies import get_supabase_service

  supabase = get_supabase_service()
  standards = NUTRITION_STANDARDS.get(recipient_group, NUTRITION_STANDARDS["sd"])

  # Parse menu
  items = await parse_menu_with_ai(menu_text)

  # Lookup nutrition untuk setiap item
  totals = {"energi_kkal": 0, "protein_g": 0, "lemak_g": 0, "karbohidrat_g": 0, "serat_g": 0}
  not_found = []

  for item in items:
    nutrition = await lookup_nutrition(item["food_name"], item["amount_g"], supabase)
    if nutrition:
      for key in totals:
        totals[key] += nutrition.get(key, 0)
    else:
      not_found.append(item["food_name"])

  # Evaluate compliance
  nutrients = []
  overall_score = 0

  for nutrient, (min_val, max_val) in standards.items():
    actual = totals.get(nutrient, 0)
    pct = (actual / min_val * 100) if min_val else 100

    if pct >= 100:
      status = "memenuhi"
      score = 100
    elif pct >= 75:
      status = "kurang"
      score = int(pct)
    else:
      status = "tidak_memenuhi"
      score = int(pct)

    nutrients.append({
      "name":       nutrient.replace("_", " ").title().replace("Kkal", "kkal").replace("G", "g"),
      "value":      round(actual, 1),
      "unit":       "kkal" if "kkal" in nutrient else "g",
      "standard":   min_val,
      "percentage": round(pct, 1),
      "status":     status,
    })
    overall_score += score

  avg_score = overall_score // len(nutrients) if nutrients else 0

  if avg_score >= 90:   overall_status = "memenuhi"
  elif avg_score >= 65: overall_status = "kurang"
  else:                 overall_status = "tidak_memenuhi"

  # Generate suggestions
  suggestions = []
  for n in nutrients:
    if n["status"] == "kurang":
      suggestions.append(f"Tambah sumber {n['name'].lower()} — masih {100 - n['percentage']:.0f}% di bawah standar")
    elif n["status"] == "tidak_memenuhi":
      suggestions.append(f"⚠️ {n['name']} sangat kurang ({n['percentage']:.0f}% dari standar) — pertimbangkan penggantian bahan")

  if not_found:
    suggestions.append(f"Catatan: {', '.join(not_found)} tidak ditemukan di database TKPI — kalkulasi mungkin kurang akurat")

  return {
    "status":      overall_status,
    "score":       avg_score,
    "nutrients":   nutrients,
    "suggestions": suggestions,
    "regulation":  "Standar Gizi MBG — Kemenkes RI & Pedoman BGN 2025",
    "items_parsed": items,
  }
```

### 3.8 — Ingestion Script (RAG Knowledge Base)

```python
[FILE: scripts/ingest/ingest_regulations.py]
"""
Script ingesti dokumen regulasi MBG ke knowledge base.
Jalankan: python scripts/ingest/ingest_regulations.py --file path/to/sk244.pdf

Pipeline:
1. Extract text dari PDF
2. Clean & normalize text
3. Chunk dengan sliding window
4. Generate embeddings (OpenAI)
5. Store ke Supabase pgvector
"""
import argparse
import asyncio
import hashlib
import re
import structlog
from pathlib import Path

log = structlog.get_logger()

def extract_text_from_pdf(pdf_path: str) -> str:
  """Extract text dari PDF menggunakan pdfplumber."""
  import pdfplumber
  text_parts = []
  with pdfplumber.open(pdf_path) as pdf:
    for page in pdf.pages:
      text = page.extract_text()
      if text:
        text_parts.append(text.strip())
  return "\n\n".join(text_parts)

def clean_text(text: str) -> str:
  """Clean dan normalize teks regulasi Indonesia."""
  # Hapus header/footer berulang
  text = re.sub(r'\n{3,}', '\n\n', text)
  # Normalize whitespace
  text = re.sub(r'[ \t]+', ' ', text)
  # Hapus karakter aneh dari OCR
  text = re.sub(r'[^\w\s\n\.\,\;\:\!\?\-\(\)\[\]\"\'\/]', '', text)
  return text.strip()

def chunk_text(text: str, chunk_size: int = 512, overlap: int = 64) -> list[dict]:
  """
  Sliding window chunking.
  Untuk dokumen regulasi Indonesia: chunk per pasal lebih baik dari word count.
  """
  chunks = []

  # Coba split per pasal dulu
  pasal_pattern = re.compile(r'(?=Pasal\s+\d+)', re.IGNORECASE)
  sections = pasal_pattern.split(text)

  if len(sections) > 3:
    # Dokumen terstruktur per pasal
    for i, section in enumerate(sections):
      if not section.strip():
        continue

      # Jika pasal terlalu panjang, sub-chunk
      words = section.split()
      if len(words) <= chunk_size:
        chunks.append({
          "text":        section.strip(),
          "chunk_index": i,
          "metadata":    {"has_pasal": True, "pasal_number": i},
        })
      else:
        # Sub-chunk panjang pasal
        for j in range(0, len(words), chunk_size - overlap):
          chunk_words = words[j:j + chunk_size]
          chunks.append({
            "text":        " ".join(chunk_words),
            "chunk_index": len(chunks),
            "metadata":    {"has_pasal": True, "pasal_number": i, "sub_chunk": j},
          })
  else:
    # Fallback: word-based chunking
    words = text.split()
    for i in range(0, len(words), chunk_size - overlap):
      chunk_words = words[i:i + chunk_size]
      chunks.append({
        "text":        " ".join(chunk_words),
        "chunk_index": i // (chunk_size - overlap),
        "metadata":    {},
      })

  return chunks

async def embed_chunks(chunks: list[dict]) -> list[dict]:
  """Generate OpenAI embeddings untuk semua chunks (batch)."""
  from openai import AsyncOpenAI
  import os

  client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))

  # Batch dalam grup 100 (OpenAI limit)
  for i in range(0, len(chunks), 100):
    batch = chunks[i:i+100]
    texts = [c["text"] for c in batch]

    response = await client.embeddings.create(
      model="text-embedding-3-small",
      input=texts,
    )

    for j, embedding_data in enumerate(response.data):
      chunks[i+j]["embedding"] = embedding_data.embedding

    log.info("Embedded batch", start=i, end=min(i+100, len(chunks)))

  return chunks

async def store_to_supabase(doc_id: str, chunks: list[dict]):
  """Store chunks dengan embeddings ke Supabase."""
  from supabase import create_client
  import os

  client = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
  )

  records = [
    {
      "doc_id":      doc_id,
      "chunk_index": c["chunk_index"],
      "chunk_text":  c["text"],
      "embedding":   c["embedding"],
      "metadata":    c.get("metadata", {}),
      "token_count": len(c["text"].split()),
    }
    for c in chunks
  ]

  # Batch insert
  for i in range(0, len(records), 50):
    await client.table("knowledge_chunks").insert(records[i:i+50]).execute()
    log.info("Stored chunks", batch=i//50 + 1, total=len(records)//50 + 1)

async def ingest_document(
  pdf_path: str,
  doc_info: dict,
):
  """Main ingestion pipeline untuk satu dokumen."""
  from supabase import create_client
  import os

  supabase = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
  )

  log.info("Starting ingestion", file=pdf_path)

  # 1. Extract text
  raw_text  = extract_text_from_pdf(pdf_path)
  clean     = clean_text(raw_text)
  log.info("Text extracted", chars=len(clean))

  # 2. Register dokumen di database
  doc_result = await supabase.table("regulation_documents").upsert({
    "short_code":     doc_info["short_code"],
    "title":          doc_info["title"],
    "type":           doc_info["type"],
    "issuer":         doc_info["issuer"],
    "effective_date": doc_info["effective_date"],
    "full_text":      clean,
  }).execute()

  doc_id = doc_result.data[0]["id"]
  log.info("Document registered", doc_id=doc_id)

  # 3. Hapus chunks lama (re-ingestion)
  await supabase.table("knowledge_chunks").delete().eq("doc_id", doc_id).execute()

  # 4. Chunk
  chunks = chunk_text(clean)
  log.info("Text chunked", num_chunks=len(chunks))

  # 5. Embed
  chunks = await embed_chunks(chunks)

  # 6. Store
  await store_to_supabase(doc_id, chunks)
  log.info("Ingestion complete", doc_id=doc_id, chunks=len(chunks))

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Ingest regulation PDF into MBGBrain knowledge base")
  parser.add_argument("--file",     required=True, help="Path to PDF file")
  parser.add_argument("--code",     required=True, help="Short code, e.g. SK_244_2025")
  parser.add_argument("--title",    required=True, help="Document title")
  parser.add_argument("--type",     default="sk",  help="Document type: sk|perpres|permen|pedoman")
  parser.add_argument("--issuer",   default="BGN", help="Issuer: BGN|Kemenkes|BPOM")
  parser.add_argument("--date",     required=True, help="Effective date: YYYY-MM-DD")
  args = parser.parse_args()

  asyncio.run(ingest_document(args.file, {
    "short_code":     args.code,
    "title":          args.title,
    "type":           args.type,
    "issuer":         args.issuer,
    "effective_date": args.date,
  }))
```

[VERIFY] Sebelum lanjut ke Fase 4:
- [ ] `uvicorn main:app --reload` berjalan di port 8000
- [ ] GET /health mengembalikan `{"status": "ok"}`
- [ ] GET /docs menampilkan Swagger UI
- [ ] POST /api/v1/chat menghasilkan SSE stream
- [ ] Script ingesti berhasil memproses minimal 1 PDF regulasi
- [ ] Unit test untuk nutrition calculator lulus

---

## Fase 4 — Integrasi & Testing (Hari 19–30)

### 4.1 — Integration Tests

```python
[FILE: apps/api/tests/test_chat.py]
"""
Test suite untuk chat endpoint.
Jalankan: pytest tests/ -v --asyncio-mode=auto
"""
import pytest
from httpx import AsyncClient
from main import app

# 50 soal domain MBG untuk evaluasi akurasi RAG
DOMAIN_TEST_QUESTIONS = [
  {"q": "Apa kewajiban hyperlocal sourcing dalam SK 244/2025?",      "keywords": ["kecamatan", "kabupaten", "lokal"]},
  {"q": "Berapa nilai kalori minimum per porsi untuk siswa SD?",      "keywords": ["kalori", "kkal", "standar"]},
  {"q": "Dokumen apa yang dibutuhkan UMKM untuk mendaftar supplier?", "keywords": ["NIB", "dokumen", "persyaratan"]},
  {"q": "Apa sanksi SPPG yang tidak comply dengan SK 244?",           "keywords": ["sanksi", "pelanggaran"]},
  # ... tambahkan hingga 50 soal
]

@pytest.mark.asyncio
async def test_chat_endpoint_returns_sse():
  async with AsyncClient(app=app, base_url="http://test") as client:
    response = await client.post(
      "/api/v1/chat",
      json={"message": "Apa itu SPPG?"},
      headers={"Authorization": "Bearer TEST_TOKEN"},
    )
  assert response.status_code == 200
  assert "text/event-stream" in response.headers["content-type"]

@pytest.mark.asyncio
async def test_menu_validator():
  async with AsyncClient(app=app, base_url="http://test") as client:
    response = await client.post(
      "/api/v1/validate-menu",
      json={
        "menu": "nasi putih 200g, ayam goreng 75g, tempe 50g, sayur bayam 100g, pisang 100g",
        "recipient_group": "sd",
      },
      headers={"Authorization": "Bearer TEST_TOKEN"},
    )
  assert response.status_code == 200
  data = response.json()
  assert "status" in data
  assert "nutrients" in data
  assert "score" in data
  assert data["score"] >= 0 and data["score"] <= 100
```

### 4.2 — Evaluation Script (RAG Accuracy)

```python
[FILE: scripts/eval/eval_rag.py]
"""
Evaluasi akurasi RAG pipeline terhadap 50 soal domain MBG.
Target: >80% pada 30 hari, >88% pada 60 hari.

Jalankan: python scripts/eval/eval_rag.py --output results/eval_$(date +%Y%m%d).json
"""
# [AGENT ACTION] Implement evaluation script yang:
# 1. Load 50 test questions dari YAML file
# 2. Jalankan setiap question melalui RAG pipeline
# 3. Cek apakah keyword jawaban yang diharapkan ada dalam response
# 4. Hitung accuracy score
# 5. Simpan hasil ke JSON dengan timestamp
# 6. Print summary report
```

### 4.3 — Docker Setup

```dockerfile
[FILE: apps/api/Dockerfile]
FROM python:3.11-slim

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Copy deps
COPY pyproject.toml .
RUN uv pip install --system -e .

# Copy source
COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

```yaml
[FILE: docker-compose.yml]
version: '3.9'
services:
  api:
    build: ./apps/api
    ports:
      - "8000:8000"
    env_file: .env
    volumes:
      - ./apps/api:/app
    depends_on:
      - redis

  web:
    build: ./apps/web
    ports:
      - "3000:3000"
    env_file: .env
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8000

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

---

## Fase 5 — Flutter Mobile App (Post-MVP, Hari 35–60)

### 5.1 — Struktur Direktori Flutter

```
apps/mobile/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart            ← MaterialApp + router
│   │   ├── theme/
│   │   │   └── mbg_theme.dart  ← design tokens MBG
│   │   └── router/
│   │       └── router.dart     ← GoRouter config
│   │
│   ├── features/
│   │   ├── auth/               ← login/register
│   │   ├── chat/               ← chatbot screen
│   │   ├── validator/          ← menu validator screen
│   │   ├── compliance/         ← compliance checker
│   │   └── suppliers/          ← supplier directory
│   │
│   ├── shared/
│   │   ├── api/
│   │   │   └── mbgbrain_api.dart  ← Dio HTTP client
│   │   ├── models/             ← data models (freezed)
│   │   └── widgets/            ← shared UI components
│   │
│   └── l10n/                   ← localization Bahasa Indonesia
│       ├── app_id.arb
│       └── app_en.arb
```

### 5.2 — Dependencies Flutter

```yaml
[FILE: apps/mobile/pubspec.yaml]
name: mbgbrain
description: MBGBrain — AI Intelligence untuk Program MBG Indonesia
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Navigation
  go_router: ^14.0.0

  # State management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Networking
  dio: ^5.4.0
  retrofit: ^4.1.0

  # UI
  flutter_animate: ^4.5.0  # mirip framer-motion
  google_fonts: ^6.2.0     # Plus Jakarta Sans
  gap: ^3.0.0

  # Auth
  supabase_flutter: ^2.5.0

  # Local storage
  hive_flutter: ^1.1.0
  secure_storage: ^9.0.0

  # Utilities
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  retrofit_generator: ^8.1.0
```

### 5.3 — Flutter Theme MBG

```dart
[FILE: apps/mobile/lib/app/theme/mbg_theme.dart]
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MBGColors {
  // Primary — Hijau organik
  static const primary = Color(0xFF2A9D5C);
  static const primaryLight = Color(0xFF4BB87E);
  static const primaryDark  = Color(0xFF196339);
  static const primarySurface = Color(0xFFF0FAF4);

  // Accent — Kunyit
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFCD34D);

  // Neutral
  static const neutral50  = Color(0xFFFAFAF8);
  static const neutral100 = Color(0xFFF5F4F0);
  static const neutral200 = Color(0xFFE9E7E0);
  static const neutral900 = Color(0xFF27251F);
}

ThemeData get mbgLightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: MBGColors.primary,
    brightness: Brightness.light,
    primary: MBGColors.primary,
    secondary: MBGColors.accent,
    surface: MBGColors.neutral50,
  ),
  textTheme: GoogleFonts.plusJakartaSansTextTheme(
    ThemeData.light().textTheme,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: MBGColors.neutral50,
    foregroundColor: MBGColors.neutral900,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: MBGColors.neutral900,
    ),
  ),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: MBGColors.neutral200),
    ),
    color: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: MBGColors.neutral200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: MBGColors.primary, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MBGColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      elevation: 0,
      textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),
);

ThemeData get mbgDarkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: MBGColors.primary,
    brightness: Brightness.dark,
    primary: MBGColors.primaryLight,
    secondary: MBGColors.accentLight,
    surface: Color(0xFF161512),
  ),
  textTheme: GoogleFonts.plusJakartaSansTextTheme(
    ThemeData.dark().textTheme,
  ),
);
```

### 5.4 — Flutter Chat Screen

```dart
[FILE: apps/mobile/lib/features/chat/screens/chat_screen.dart]
// [AGENT ACTION] Implement chat screen Flutter dengan:
// - StreamBuilder untuk SSE dari FastAPI
// - Bubble message mirip WhatsApp tapi green theme
// - Citation expandable card
// - Typing indicator animasi (3 dots)
// - Quick prompt chips di empty state
// - Input field dengan send button
// - Platform-adaptive: cupertino on iOS, material on Android
```

---

## Fase 6 — Deployment & Monitoring (Hari 31–35)

### 6.1 — Vercel Deployment (Frontend)

```json
[FILE: apps/web/vercel.json]
{
  "buildCommand": "pnpm build",
  "outputDirectory": ".next",
  "installCommand": "pnpm install",
  "framework": "nextjs",
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL":      "@supabase_url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase_anon_key",
    "NEXT_PUBLIC_API_URL":           "@api_url"
  },
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options",        "value": "DENY" },
        { "key": "X-XSS-Protection",       "value": "1; mode=block" }
      ]
    }
  ]
}
```

### 6.2 — Railway Deployment (Backend)

```toml
[FILE: apps/api/railway.toml]
[build]
builder = "dockerfile"
dockerfilePath = "Dockerfile"

[deploy]
startCommand = "uvicorn main:app --host 0.0.0.0 --port $PORT --workers 2"
healthcheckPath = "/health"
healthcheckTimeout = 30
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 3

[environments.production]
PORT = "8000"
```

### 6.3 — Monitoring & Alerting

```python
[FILE: apps/api/app/core/logger.py]
"""Structured logging setup dengan structlog."""
import structlog
import logging

def setup_logging():
  structlog.configure(
    processors=[
      structlog.contextvars.merge_contextvars,
      structlog.processors.add_log_level,
      structlog.processors.TimeStamper(fmt="iso"),
      structlog.processors.StackInfoRenderer(),
      structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
  )
```

---

## Checklist Final — Definition of Done per Modul

### Modul 1: MBG Regulatory Assistant
- [ ] Akurasi >85% pada 50 soal domain MBG
- [ ] Response time P95 < 5 detik
- [ ] Citation regulasi tampil di setiap jawaban
- [ ] Context window 10+ giliran dalam satu sesi
- [ ] Graceful handling untuk pertanyaan di luar domain MBG

### Modul 2: Nutrition Menu Validator
- [ ] Parse >90% input menu Indonesia tanpa error
- [ ] Margin error kalkulasi gizi <10% vs manual TKPI
- [ ] Output PDF dapat diunduh
- [ ] Support 4 kelompok penerima (SD, SMP, balita, bumil)

### Modul 3: SK 244 Compliance Checker
- [ ] Mencakup seluruh persyaratan material SK 244/2025
- [ ] Laporan compliance dapat diunduh dengan tanggal & versi regulasi
- [ ] Peringatan persyaratan belum terpenuhi + panduan tindak lanjut

### Modul 4: UMKM Supplier Directory
- [ ] Pencarian hasil <3 detik untuk 1.000+ supplier
- [ ] Profil UMKM dapat dibuat <5 menit
- [ ] Geospatial filter radius berfungsi
- [ ] Indikator kelengkapan profil tampil

### Modul 5: REST API
- [ ] 5 endpoint core didokumentasikan di Swagger
- [ ] Rate limiting per API key berfungsi
- [ ] Header `X-Regulation-Version` di setiap response
- [ ] Webhook notifikasi update regulasi

### Cross-cutting
- [ ] Test coverage >70% untuk modul inti
- [ ] HTTPS/TLS di semua endpoint
- [ ] API Key di-hash sebelum disimpan
- [ ] Sentry error tracking aktif
- [ ] Uptime monitoring aktif
- [ ] RLS Supabase diuji untuk semua role
- [ ] Tidak ada PII yang diteruskan ke LLM tanpa consent

---

## Urutan Eksekusi Agent

```
Fase 1 → UI/UX Frontend (Next.js)     [Hari 1–7]   ← MULAI DI SINI
Fase 2 → Database Supabase             [Hari 5–7]   ← overlap dengan Fase 1
Fase 3 → FastAPI Backend + RAG         [Hari 8–18]
Fase 4 → Integrasi, Testing, Ingesti  [Hari 19–30]
Fase 5 → Flutter Mobile (post-MVP)     [Hari 35–60]
Fase 6 → Deployment & Monitoring       [Hari 31–35]
```

> **Catatan penting untuk agent:**
> Selalu baca `PRD.md` sebagai sumber kebenaran untuk requirements.
> Ketika ada konflik antara AGENTS.md dan PRD.md, PRD.md lebih diprioritaskan.
> Dokumentasikan setiap keputusan teknis yang berbeda dari PRD di `docs/adr/` (Architecture Decision Records).
```
