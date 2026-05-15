'use client';

import { motion, useMotionValue, useSpring, useTransform } from 'framer-motion';
import { useEffect } from 'react';

const ORBS = [
  { size: 420, x: '10%', y: '15%', color: 'rgba(42, 157, 92, 0.35)', duration: 22 },
  { size: 320, x: '75%', y: '8%', color: 'rgba(245, 158, 11, 0.28)', duration: 18 },
  { size: 380, x: '60%', y: '55%', color: 'rgba(75, 184, 126, 0.22)', duration: 26 },
  { size: 260, x: '5%', y: '65%', color: 'rgba(42, 157, 92, 0.2)', duration: 20 },
];

const PARTICLES = Array.from({ length: 24 }, (_, i) => ({
  id: i,
  left: `${(i * 17 + 7) % 100}%`,
  top: `${(i * 23 + 11) % 100}%`,
  delay: i * 0.15,
  size: 2 + (i % 4),
}));

export function InteractiveBackground() {
  const mouseX = useMotionValue(0.5);
  const mouseY = useMotionValue(0.5);
  const springX = useSpring(mouseX, { stiffness: 40, damping: 20 });
  const springY = useSpring(mouseY, { stiffness: 40, damping: 20 });

  const parallaxX = useTransform(springX, [0, 1], [-30, 30]);
  const parallaxY = useTransform(springY, [0, 1], [-20, 20]);

  useEffect(() => {
    const onMove = (e: MouseEvent) => {
      mouseX.set(e.clientX / window.innerWidth);
      mouseY.set(e.clientY / window.innerHeight);
    };
    window.addEventListener('mousemove', onMove);
    return () => window.removeEventListener('mousemove', onMove);
  }, [mouseX, mouseY]);

  return (
    <div className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
      <div className="absolute inset-0 bg-neutral-50 dark:bg-[#0f0e0c]" />
      <div
        className="absolute inset-0 opacity-40 dark:opacity-30"
        style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' stroke='%232a9d5c' stroke-opacity='0.08' stroke-width='1'%3E%3Cpath d='M0 0h60v60H0z'/%3E%3C/g%3E%3C/svg%3E")`,
        }}
      />
      <motion.div style={{ x: parallaxX, y: parallaxY }} className="absolute inset-0">
        {ORBS.map((orb, i) => (
          <motion.div
            key={i}
            className="absolute rounded-full blur-3xl"
            style={{
              width: orb.size,
              height: orb.size,
              left: orb.x,
              top: orb.y,
              background: orb.color,
            }}
            animate={{
              x: [0, 40, -20, 0],
              y: [0, -30, 25, 0],
              scale: [1, 1.08, 0.95, 1],
            }}
            transition={{ duration: orb.duration, repeat: Infinity, ease: 'easeInOut' }}
          />
        ))}
      </motion.div>
      {PARTICLES.map((p) => (
        <motion.div
          key={p.id}
          className="absolute rounded-full bg-primary-400/40"
          style={{ left: p.left, top: p.top, width: p.size, height: p.size }}
          animate={{ y: [0, -18, 0], opacity: [0.2, 0.7, 0.2] }}
          transition={{ duration: 4 + (p.id % 3), repeat: Infinity, delay: p.delay }}
        />
      ))}
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-neutral-50/50 to-neutral-50 dark:via-[#0f0e0c]/50 dark:to-[#0f0e0c]" />
    </div>
  );
}
