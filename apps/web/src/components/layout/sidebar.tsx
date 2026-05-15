'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import {
  MessageSquare,
  ChefHat,
  ShieldCheck,
  Store,
  History,
  Settings,
  ChevronLeft,
  ChevronRight,
  Plus,
  Moon,
  Sun,
  Menu,
} from 'lucide-react';
import { useTheme } from 'next-themes';
import { cn } from '@/lib/utils';
import { ChatMBGLogo } from '@/components/brand/chatmbg-logo';

const NAV_ITEMS = [
  {
    group: 'Asisten AI',
    items: [
      { href: '/chat', icon: MessageSquare, label: 'Regulasi Assistant', badge: null },
      { href: '/validator', icon: ChefHat, label: 'Validator Menu Gizi', badge: 'NEW' },
      { href: '/compliance', icon: ShieldCheck, label: 'Cek Kepatuhan SK 244', badge: null },
      { href: '/suppliers', icon: Store, label: 'Direktori UMKM', badge: null },
    ],
  },
  {
    group: 'Riwayat',
    items: [{ href: '/history', icon: History, label: 'Riwayat Query', badge: null }],
  },
];

interface SidebarProps {
  className?: string;
  mobileOpen?: boolean;
  onMobileClose?: () => void;
}

function SidebarContent({
  collapsed,
  onCollapse,
  onNavClick,
}: {
  collapsed: boolean;
  onCollapse?: () => void;
  onNavClick?: () => void;
}) {
  const pathname = usePathname();
  const { theme, setTheme } = useTheme();

  return (
    <>
      <motion.aside
        animate={{ width: collapsed ? 64 : 260 }}
        transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
        className={cn(
          'relative flex h-full flex-col border-r border-neutral-200 dark:border-neutral-800',
          'bg-neutral-50 dark:bg-neutral-900'
        )}
      >
        <motion.div
          animate={{ width: collapsed ? 64 : 260 }}
          transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
          className="flex h-16 items-center border-b border-neutral-200 px-4 dark:border-neutral-800"
        >
          <motion.div
            animate={{ width: collapsed ? 32 : 220 }}
            transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
            className="flex items-center gap-2.5 overflow-hidden"
          >
            <ChatMBGLogo size={32} showText={!collapsed} />
          </motion.div>
        </motion.div>

        <div className="p-3">
          <Link
            href="/chat"
            onClick={onNavClick}
            className={cn(
              'flex items-center gap-2.5 rounded-xl px-3 py-2.5 text-sm font-medium',
              'bg-primary-500 text-white transition-all duration-150 hover:bg-primary-600 active:scale-95',
              collapsed && 'justify-center px-0'
            )}
          >
            <Plus className="h-4 w-4 shrink-0" />
            {!collapsed && <span>Mulai Chat Baru</span>}
          </Link>
        </div>

        <nav className="flex-1 space-y-4 overflow-y-auto px-3 pb-2">
          {NAV_ITEMS.map((group) => (
            <motion.div
              key={group.group}
              animate={{ width: collapsed ? 40 : 236 }}
              transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
            >
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
                        onClick={onNavClick}
                        className={cn(
                          'group flex items-center gap-2.5 rounded-xl px-3 py-2 text-sm transition-all duration-150',
                          active
                            ? 'bg-primary-50 font-medium text-primary-700 dark:bg-primary-900/30 dark:text-primary-300'
                            : 'text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 dark:text-neutral-400 dark:hover:bg-neutral-800 dark:hover:text-neutral-100',
                          collapsed && 'mx-auto w-10 justify-center px-0'
                        )}
                        title={collapsed ? item.label : undefined}
                      >
                        <item.icon
                          className={cn(
                            'h-4 w-4 shrink-0',
                            active && 'text-primary-600 dark:text-primary-400'
                          )}
                        />
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
            </motion.div>
          ))}
        </nav>

        <div className="space-y-1 border-t border-neutral-200 p-3 dark:border-neutral-800">
          <button
            type="button"
            onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
            className={cn(
              'flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-sm',
              'text-neutral-500 transition-all duration-150 hover:bg-neutral-100 hover:text-neutral-900 dark:hover:bg-neutral-800 dark:hover:text-neutral-100',
              collapsed && 'mx-auto w-10 justify-center px-0'
            )}
          >
            {theme === 'dark' ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
            {!collapsed && <span>Tampilan {theme === 'dark' ? 'Terang' : 'Gelap'}</span>}
          </button>

          <Link
            href="/settings"
            onClick={onNavClick}
            className={cn(
              'flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-sm',
              'text-neutral-500 transition-all duration-150 hover:bg-neutral-100 hover:text-neutral-900 dark:hover:bg-neutral-800 dark:hover:text-neutral-100',
              collapsed && 'mx-auto w-10 justify-center px-0'
            )}
          >
            <Settings className="h-4 w-4" />
            {!collapsed && <span>Pengaturan</span>}
          </Link>
        </div>

        {onCollapse && (
          <button
            type="button"
            onClick={onCollapse}
            className={cn(
              'absolute -right-3 top-20 z-10 hidden h-6 w-6 items-center justify-center md:flex',
              'rounded-full border border-neutral-200 bg-white text-neutral-500 shadow-sm',
              'transition-all duration-150 hover:bg-neutral-50 dark:border-neutral-700 dark:bg-neutral-900 dark:hover:bg-neutral-800'
            )}
          >
            {collapsed ? <ChevronRight className="h-3 w-3" /> : <ChevronLeft className="h-3 w-3" />}
          </button>
        )}
      </motion.aside>
    </>
  );
}

export function Sidebar({ className, mobileOpen, onMobileClose }: SidebarProps) {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <>
      {/* Desktop */}
      <motion.div
        animate={{ width: collapsed ? 64 : 260 }}
        transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
        className={cn('relative hidden h-screen shrink-0 md:block', className)}
      >
        <SidebarContent collapsed={collapsed} onCollapse={() => setCollapsed(!collapsed)} />
      </motion.div>

      {/* Mobile overlay */}
      <AnimatePresence>
        {mobileOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-40 bg-black/40 md:hidden"
              onClick={onMobileClose}
            />
            <motion.div
              initial={{ x: -280 }}
              animate={{ x: 0 }}
              exit={{ x: -280 }}
              transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
              className="fixed inset-y-0 left-0 z-50 md:hidden"
            >
              <SidebarContent collapsed={false} onNavClick={onMobileClose} />
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}

export function MobileHeader({ onMenuOpen }: { onMenuOpen: () => void }) {
  return (
    <header className="flex h-14 items-center justify-between border-b border-neutral-200 bg-neutral-50 px-4 dark:border-neutral-800 dark:bg-neutral-900 md:hidden">
      <button
        type="button"
        onClick={onMenuOpen}
        className="flex h-9 w-9 items-center justify-center rounded-xl text-neutral-600 hover:bg-neutral-100 dark:text-neutral-400 dark:hover:bg-neutral-800"
        aria-label="Buka menu"
      >
        <Menu className="h-5 w-5" />
      </button>
      <Link href="/">
        <ChatMBGLogo size={32} showText />
      </Link>
      <div className="w-9" />
    </header>
  );
}
