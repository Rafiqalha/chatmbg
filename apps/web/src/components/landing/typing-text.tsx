'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

interface TypingTextProps {
  phrases: string[];
  className?: string;
  typingSpeed?: number;
  pauseMs?: number;
}

export function TypingText({
  phrases,
  className,
  typingSpeed = 45,
  pauseMs = 2200,
}: TypingTextProps) {
  const [phraseIndex, setPhraseIndex] = useState(0);
  const [displayed, setDisplayed] = useState('');
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    const current = phrases[phraseIndex] ?? '';
    let timeout: ReturnType<typeof setTimeout>;

    if (!isDeleting && displayed.length < current.length) {
      timeout = setTimeout(() => {
        setDisplayed(current.slice(0, displayed.length + 1));
      }, typingSpeed);
    } else if (!isDeleting && displayed.length === current.length) {
      timeout = setTimeout(() => setIsDeleting(true), pauseMs);
    } else if (isDeleting && displayed.length > 0) {
      timeout = setTimeout(() => {
        setDisplayed(current.slice(0, displayed.length - 1));
      }, typingSpeed / 2);
    } else {
      setIsDeleting(false);
      setPhraseIndex((i) => (i + 1) % phrases.length);
    }

    return () => clearTimeout(timeout);
  }, [displayed, isDeleting, phraseIndex, phrases, typingSpeed, pauseMs]);

  return (
    <span className={className}>
      {displayed}
      <motion.span
        animate={{ opacity: [1, 0.2, 1] }}
        transition={{ duration: 0.8, repeat: Infinity }}
        className="ml-0.5 inline-block h-[1em] w-[2px] translate-y-[2px] bg-primary-500 align-middle"
        aria-hidden
      />
    </span>
  );
}
