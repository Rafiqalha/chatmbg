'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { Mail, Lock, User, Loader2 } from 'lucide-react';
import { ChatMBGLogo } from '@/components/brand/chatmbg-logo';
import toast from 'react-hot-toast';
import { createClient } from '@/lib/supabase/client';
import { cn } from '@/lib/utils';

export default function RegisterPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

    if (!supabaseUrl?.includes('supabase.co') || supabaseKey === 'your-anon-key') {
      toast.success('Mode demo — akun terdaftar, masuk ke dashboard');
      router.push('/chat');
      setLoading(false);
      return;
    }

    try {
      const supabase = createClient();
      const { error } = await supabase.auth.signUp({
        email,
        password,
        options: { data: { full_name: fullName } },
      });
      if (error) throw error;
      toast.success('Cek email Anda untuk verifikasi akun');
      router.push('/login');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Gagal mendaftar');
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
          Daftar ChatMBG
        </h1>
        <p className="mt-1 text-sm text-neutral-500">Untuk SPPG, UMKM, dan pemangku kepentingan MBG</p>
      </div>

      <form onSubmit={handleRegister} className="space-y-4">
        <motion.div
          initial={{ opacity: 0, y: 6 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.05 }}
        >
          <label className="mb-1.5 block text-sm font-medium text-neutral-700 dark:text-neutral-300">
            Nama lengkap
          </label>
          <div className="relative">
            <User className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-neutral-400" />
            <input
              type="text"
              required
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="Ibu Ratna"
              className="w-full rounded-xl border border-neutral-200 py-2.5 pl-10 pr-4 text-sm focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-100"
            />
          </div>
        </motion.div>
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
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-neutral-400" />
            <input
              type="password"
              required
              minLength={8}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Min. 8 karakter"
              className="w-full rounded-xl border border-neutral-200 py-2.5 pl-10 pr-4 text-sm focus:border-primary-400 focus:outline-none dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-100"
            />
          </div>
        </div>
        <button
          type="submit"
          disabled={loading}
          className={cn(
            'flex w-full items-center justify-center gap-2 rounded-xl bg-primary-500 py-3 text-sm font-semibold text-white',
            'transition-all hover:bg-primary-600 disabled:opacity-70'
          )}
        >
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Daftar Sekarang'}
        </button>
      </form>

      <p className="mt-6 text-center text-sm text-neutral-500">
        Sudah punya akun?{' '}
        <Link href="/login" className="font-medium text-primary-600 hover:underline dark:text-primary-400">
          Masuk
        </Link>
      </p>
    </motion.div>
  );
}
