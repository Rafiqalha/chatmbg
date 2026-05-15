'use client';

import { useState } from 'react';
import { Sidebar, MobileHeader } from '@/components/layout/sidebar';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <div className="flex h-screen overflow-hidden bg-neutral-50 dark:bg-neutral-950">
      <Sidebar mobileOpen={mobileOpen} onMobileClose={() => setMobileOpen(false)} />
      <div className="flex min-w-0 flex-1 flex-col overflow-hidden">
        <MobileHeader onMenuOpen={() => setMobileOpen(true)} />
        <main className="flex-1 overflow-hidden">{children}</main>
      </div>
    </div>
  );
}
