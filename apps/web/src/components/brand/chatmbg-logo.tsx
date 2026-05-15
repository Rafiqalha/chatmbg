'use client';

import Image from 'next/image';
import { useState } from 'react';
import { Leaf } from 'lucide-react';
import { cn } from '@/lib/utils';

/** Logo paths to try from public/logo (user-provided assets) */
const LOGO_CANDIDATES = [
  '/logo/logo-chatmbg.png',
  '/logo/logo.png',
  '/logo/logo.svg',
  '/logo/chatmbg.png',
  '/logo/chatmbg.svg',
  '/logo/ChatMBG.png',
  '/logo/ChatMBG.svg',
];

interface ChatMBGLogoProps {
  size?: number;
  showText?: boolean;
  className?: string;
  textClassName?: string;
}

export function ChatMBGLogo({ size = 36, showText = true, className, textClassName }: ChatMBGLogoProps) {
  const [srcIndex, setSrcIndex] = useState(0);
  const [failed, setFailed] = useState(false);

  const src = LOGO_CANDIDATES[srcIndex];

  return (
    <div className={cn('flex items-center gap-2.5', className)}>
      <div
        className="relative shrink-0 overflow-hidden rounded-xl bg-primary-500/10 ring-1 ring-primary-500/20"
        style={{ width: size, height: size }}
      >
        {!failed && srcIndex < LOGO_CANDIDATES.length ? (
          <Image
            src={src}
            alt="ChatMBG"
            width={size}
            height={size}
            className="object-contain p-1"
            onError={() => {
              if (srcIndex + 1 < LOGO_CANDIDATES.length) {
                setSrcIndex((i) => i + 1);
              } else {
                setFailed(true);
              }
            }}
            priority
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-primary-500">
            <Leaf className="text-white" style={{ width: size * 0.5, height: size * 0.5 }} />
          </div>
        )}
      </div>
      {showText && (
        <div className={textClassName}>
          <span className="font-display text-[15px] font-bold leading-none text-neutral-900 dark:text-neutral-50">
            Chat<span className="text-primary-500">MBG</span>
          </span>
          <p className="mt-0.5 text-[10px] text-neutral-500">AI untuk Program MBG</p>
        </div>
      )}
    </div>
  );
}
