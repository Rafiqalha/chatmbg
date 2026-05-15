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
