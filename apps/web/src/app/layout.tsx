import type { Metadata, Viewport } from 'next';
import { ThemeProvider } from '@/components/providers/theme-provider';
import { QueryProvider } from '@/components/providers/query-provider';
import { Toaster } from 'react-hot-toast';
import { Analytics } from '@vercel/analytics/react';
import './globals.css';

export const metadata: Metadata = {
  title: {
    default: 'ChatMBG — AI Intelligence untuk Program Makan Bergizi Gratis',
    template: '%s | ChatMBG',
  },
  description:
    'Platform AI untuk SPPG, UMKM, dan ekosistem Makan Bergizi Gratis Indonesia. Validasi menu, cek regulasi, dan matching supplier dalam satu platform.',
  keywords: ['MBG', 'Makan Bergizi Gratis', 'SPPG', 'AI', 'regulasi', 'gizi'],
  authors: [{ name: 'ChatMBG' }],
  openGraph: {
    type: 'website',
    locale: 'id_ID',
    url: 'https://chatmbg.id',
    title: 'ChatMBG — AI Intelligence untuk MBG Indonesia',
    description: 'Validasi menu, cek regulasi SK 244, dan matching UMKM supplier.',
    siteName: 'ChatMBG',
  },
  robots: { index: true, follow: true },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#f5f4f0' },
    { media: '(prefers-color-scheme: dark)', color: '#161512' },
  ],
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="id" suppressHydrationWarning>
      <body className="min-h-screen antialiased">
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          <QueryProvider>
            {children}
            <Toaster
              position="bottom-center"
              toastOptions={{
                style: {
                  background: 'rgb(var(--surface))',
                  color: 'rgb(var(--foreground))',
                  border: '1px solid rgb(var(--border))',
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
