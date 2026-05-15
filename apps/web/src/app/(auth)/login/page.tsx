'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { Mail, Lock, Loader2 } from 'lucide-react';
import { ChatMBGLogo } from '@/components/brand/chatmbg-logo';
import toast from 'react-hot-toast';
import { createClient } from '@/lib/supabase/client';
import { cn } from '@/lib/utils';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

    if (!supabaseUrl?.includes('supabase.co') || supabaseKey === 'your-anon-key') {
      toast.success('Mode demo — masuk ke dashboard');
      router.push('/chat');
      setLoading(false);
      return;
    }

    try {
      const supabase = createClient();
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;
      toast.success('Berhasil masuk');
      router.push('/chat');
      router.refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Gagal masuk');
    } finally {
      setLoading(false);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      className="rounded-3xl border border-neutral-200 bg-white p-8 shadow-sm dark:border-neutral-800 dark:bg-neutral-900"
    >
      <div className="mb-8 text-center">
        <ChatMBGLogo size={48} showText={false} className="mx-auto mb-4 justify-center" />
        <h1 className="font-display text-xl font-bold text-neutral-900 dark:text-neutral-50">
          Masuk ke ChatMBG
        </h1>
        <p className="mt-1 text-sm text-neutral-500">Platform AI untuk program MBG Indonesia</p>
      </div>

      <form onSubmit={handleLogin} className="space-y-4">
        <div>
          <label className="mb-1.5 block text-sm font-medium text-neutral-700 dark:text-neutral-300">
            Email
          </label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-neutral-400" />
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="nama@sppg.go.id"
              className="w-full rounded-xl border border-neutral-200 py-2.5 pl-10 pr-4 text-sm focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-100"
            />
          </div>
        </div>
        <div>
          <label className="mb-1.5 block text-sm font-medium text-neutral-700 dark:text-neutral-300">
            Kata sandi
          </label>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.1 }}
            className="relative"
          >
            <Lock className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-neutral-400" />
            <input
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              className="w-full rounded-xl border border-neutral-200 py-2.5 pl-10 pr-4 text-sm focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-100"
            />
          </motion.div>
        </div>
        <button
          type="submit"
          disabled={loading}
          className={cn(
            'flex w-full items-center justify-center gap-2 rounded-xl bg-primary-500 py-3 text-sm font-semibold text-white',
            'transition-all hover:bg-primary-600 disabled:opacity-70'
          )}
        >
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Masuk'}
        </button>
      </form>

      <p className="mt-6 text-center text-sm text-neutral-500">
        Belum punya akun?{' '}
        <Link href="/register" className="font-medium text-primary-600 hover:underline dark:text-primary-400">
          Daftar gratis
        </Link>
      </p>
      <p className="mt-4 text-center">
        <Link href="/chat" className="text-xs text-neutral-400 hover:text-primary-500">
          Lanjut tanpa login (demo) →
        </Link>
      </p>
    </motion.div>
  );
}
