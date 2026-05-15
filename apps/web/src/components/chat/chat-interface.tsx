'use client';

import { useState, useRef, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Send,
  StopCircle,
  RefreshCw,
  Copy,
  ThumbsUp,
  ThumbsDown,
  Leaf,
  BookOpen,
  AlertCircle,
  type LucideIcon,
} from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import toast from 'react-hot-toast';
import { cn } from '@/lib/utils';
import { DEMO_CHAT_RESPONSE, DEMO_CITATIONS } from '@/lib/mock/demo-data';

interface Citation {
  regulation: string;
  article: string;
  excerpt: string;
}

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  citations?: Citation[];
  timestamp: Date;
  status: 'pending' | 'streaming' | 'done' | 'error';
  isDemo?: boolean;
}

const QUICK_PROMPTS = [
  { icon: '📋', text: 'Apa syarat menjadi supplier resmi MBG?', category: 'UMKM' },
  {
    icon: '🥗',
    text: 'Validasi menu: nasi, ayam, tempe, sayur bayam, pisang untuk siswa SD',
    category: 'Validator',
  },
  {
    icon: '🔍',
    text: 'Jelaskan kewajiban hyperlocal sourcing dalam SK 244/2025',
    category: 'Regulasi',
  },
  {
    icon: '📊',
    text: 'Dokumen apa yang dibutuhkan untuk persiapan audit BPKP?',
    category: 'Compliance',
  },
];

function CitationCard({ citations }: { citations: Citation[] }) {
  const [expanded, setExpanded] = useState(false);
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
      className="mt-3 overflow-hidden rounded-xl border border-primary-200 bg-primary-50 dark:border-primary-800/50 dark:bg-primary-900/20"
    >
      <button
        type="button"
        onClick={() => setExpanded(!expanded)}
        className="flex w-full items-center gap-2 px-3 py-2 text-left"
      >
        <BookOpen className="h-3.5 w-3.5 shrink-0 text-primary-600 dark:text-primary-400" />
        <span className="flex-1 text-xs font-medium text-primary-700 dark:text-primary-300">
          {citations.length} sumber regulasi
        </span>
        <span className="text-xs text-primary-500">{expanded ? '▲' : '▼'}</span>
      </button>
      <AnimatePresence>
        {expanded && (
          <motion.div
            initial={{ height: 0 }}
            animate={{ height: 'auto' }}
            exit={{ height: 0 }}
            className="overflow-hidden"
          >
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
              className="divide-y divide-primary-100 border-t border-primary-200 dark:divide-primary-800/30 dark:border-primary-800/50"
            >
              {citations.map((c, i) => (
                <div key={i} className="px-3 py-2">
                  <motion.div
                    initial={{ opacity: 0, x: -6 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: i * 0.05, duration: 0.2 }}
                    className="mb-1 flex items-center gap-2"
                  >
                    <span className="rounded-md bg-primary-500 px-1.5 py-0.5 text-[10px] font-bold text-white">
                      {c.regulation}
                    </span>
                    <span className="text-[11px] font-medium text-primary-600 dark:text-primary-400">
                      {c.article}
                    </span>
                  </motion.div>
                  <p className="text-xs italic leading-relaxed text-neutral-600 dark:text-neutral-400">
                    &ldquo;{c.excerpt}&rdquo;
                  </p>
                </div>
              ))}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

function TypingIndicator() {
  return (
    <div className="flex items-center gap-1.5 px-4 py-3">
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary-500">
        <Leaf className="h-4 w-4 text-white" />
      </div>
      <div className="flex items-center gap-1 rounded-2xl border border-neutral-200 bg-white px-4 py-3 dark:border-neutral-700 dark:bg-neutral-800">
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

function ActionButton({
  icon: Icon,
  title,
  onClick,
}: {
  icon: LucideIcon;
  title: string;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      title={title}
      className="flex h-7 w-7 items-center justify-center rounded-lg text-neutral-400 transition-all hover:bg-neutral-100 hover:text-neutral-600 dark:hover:bg-neutral-800 dark:hover:text-neutral-300"
    >
      <Icon className="h-3.5 w-3.5" />
    </button>
  );
}

function MessageBubble({ message, isLast }: { message: Message; isLast: boolean }) {
  const isUser = message.role === 'user';

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
      className={cn('group flex gap-3 px-4 py-2', isUser && 'flex-row-reverse')}
    >
      {!isUser && (
        <div className="mt-1 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary-500">
          <Leaf className="h-4 w-4 text-white" />
        </div>
      )}

      <motion.div
        initial={{ opacity: 0, scale: 0.98 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
        className={cn('max-w-[85%] space-y-1 sm:max-w-[80%]', isUser && 'flex flex-col items-end')}
      >
        {isUser ? (
          <div className="rounded-2xl rounded-tr-sm bg-primary-500 px-4 py-3 text-sm leading-relaxed text-white">
            {message.content}
          </div>
        ) : (
          <div className="rounded-2xl rounded-tl-sm border border-neutral-200 bg-white px-4 py-3 dark:border-neutral-700 dark:bg-neutral-800">
            {message.status === 'error' ? (
              <div className="flex items-center gap-2 text-sm text-red-600 dark:text-red-400">
                <AlertCircle className="h-4 w-4" />
                <span>Terjadi kesalahan. Coba lagi.</span>
              </div>
            ) : (
              <div className="prose-mbg text-sm leading-relaxed text-neutral-800 dark:text-neutral-200">
                <ReactMarkdown remarkPlugins={[remarkGfm]}>{message.content}</ReactMarkdown>
              </div>
            )}
            {message.isDemo && message.status === 'done' && (
              <p className="mt-2 text-[10px] text-accent-600 dark:text-accent-400">
                Mode demo — hubungkan API backend untuk jawaban RAG penuh
              </p>
            )}
            {message.citations && message.citations.length > 0 && (
              <CitationCard citations={message.citations} />
            )}
          </div>
        )}

        {!isUser && message.status === 'done' && (
          <div className="flex items-center gap-1 opacity-0 transition-opacity duration-150 group-hover:opacity-100">
            <ActionButton
              icon={Copy}
              title="Salin"
              onClick={() => {
                navigator.clipboard.writeText(message.content);
                toast.success('Disalin ke clipboard');
              }}
            />
            <ActionButton icon={ThumbsUp} title="Membantu" onClick={() => toast.success('Terima kasih!')} />
            <ActionButton icon={ThumbsDown} title="Tidak membantu" onClick={() => toast('Feedback dicatat')} />
            {isLast && <ActionButton icon={RefreshCw} title="Coba lagi" onClick={() => {}} />}
          </div>
        )}
      </motion.div>
    </motion.div>
  );
}

function EmptyState({ onPromptClick }: { onPromptClick: (text: string) => void }) {
  return (
    <div className="flex flex-1 flex-col items-center justify-center p-6 text-center sm:p-8">
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.4 }}
      >
        <div className="mb-6 flex items-center justify-center">
          <div className="relative">
            <div className="flex h-20 w-20 items-center justify-center rounded-3xl bg-gradient-to-br from-primary-400 to-primary-600 shadow-lg shadow-primary-500/25">
              <Leaf className="h-10 w-10 text-white" />
            </div>
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.2, type: 'spring', stiffness: 400 }}
              className="absolute -bottom-1 -right-1 flex h-6 w-6 items-center justify-center rounded-full bg-accent-400 text-xs font-bold text-white"
            >
              AI
            </motion.div>
          </div>
        </div>

        <h1 className="font-display mb-2 text-2xl font-semibold text-neutral-900 dark:text-neutral-100">
          Selamat datang di ChatMBG
        </h1>
        <p className="mx-auto mb-8 max-w-sm text-sm text-neutral-500 dark:text-neutral-400">
          Asisten AI untuk program Makan Bergizi Gratis. Tanyakan regulasi, validasi menu, atau cari
          supplier UMKM.
        </p>

        <div className="mx-auto grid max-w-lg grid-cols-1 gap-2.5 sm:grid-cols-2">
          {QUICK_PROMPTS.map((p, i) => (
            <motion.button
              key={p.text}
              type="button"
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 + i * 0.05 }}
              onClick={() => onPromptClick(p.text)}
              className={cn(
                'group flex items-start gap-3 rounded-2xl border border-neutral-200 p-3.5 text-left',
                'bg-white dark:border-neutral-700 dark:bg-neutral-800/50',
                'transition-all duration-200 hover:border-primary-300 hover:bg-primary-50 active:scale-[0.98]',
                'dark:hover:border-primary-700 dark:hover:bg-primary-900/20'
              )}
            >
              <span className="text-xl">{p.icon}</span>
              <div>
                <span className="mb-0.5 block text-[10px] font-semibold uppercase tracking-wider text-primary-500">
                  {p.category}
                </span>
                <span className="text-sm leading-snug text-neutral-700 dark:text-neutral-300">
                  {p.text}
                </span>
              </div>
            </motion.button>
          ))}
        </div>
      </motion.div>
    </div>
  );
}

async function streamDemoResponse(
  assistantId: string,
  onUpdate: (content: string, citations: Citation[], done: boolean) => void
) {
  const citations = DEMO_CITATIONS;
  onUpdate('', citations, false);

  const words = DEMO_CHAT_RESPONSE.split(' ');
  let accumulated = '';
  for (let i = 0; i < words.length; i++) {
    accumulated += (i > 0 ? ' ' : '') + words[i];
    onUpdate(accumulated, citations, false);
    await new Promise((r) => setTimeout(r, 35));
  }
  onUpdate(accumulated, citations, true);
}

export function ChatInterface() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const abortRef = useRef(false);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  useEffect(() => {
    if (inputRef.current) {
      inputRef.current.style.height = 'auto';
      inputRef.current.style.height = `${Math.min(inputRef.current.scrollHeight, 160)}px`;
    }
  }, [input]);

  const sendMessage = useCallback(
    async (text?: string) => {
      const content = (text ?? input).trim();
      if (!content || isLoading) return;

      const userMsg: Message = {
        id: crypto.randomUUID(),
        role: 'user',
        content,
        timestamp: new Date(),
        status: 'done',
      };

      const assistantMsg: Message = {
        id: crypto.randomUUID(),
        role: 'assistant',
        content: '',
        timestamp: new Date(),
        status: 'streaming',
      };

      setMessages((prev) => [...prev, userMsg, assistantMsg]);
      setInput('');
      setIsLoading(true);
      abortRef.current = false;

      const apiUrl = process.env.NEXT_PUBLIC_API_URL;

      try {
        const res = await fetch(`${apiUrl}/api/v1/chat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message: content }),
        });

        if (!res.ok) throw new Error('API error');

        const reader = res.body?.getReader();
        const decoder = new TextDecoder();

        if (reader) {
          let accumulated = '';
          let citations: Citation[] = [];

          while (true) {
            if (abortRef.current) break;
            const { done, value } = await reader.read();
            if (done) break;

            const chunk = decoder.decode(value, { stream: true });
            const lines = chunk.split('\n').filter((l) => l.startsWith('data: '));

            for (const line of lines) {
              const data = line.replace('data: ', '');
              if (data === '[DONE]') break;
              try {
                const parsed = JSON.parse(data);
                if (parsed.delta) accumulated += parsed.delta;
                if (parsed.citations) citations = parsed.citations;
                setMessages((prev) =>
                  prev.map((m) =>
                    m.id === assistantMsg.id
                      ? { ...m, content: accumulated, citations, status: 'streaming' }
                      : m
                  )
                );
              } catch {
                /* skip malformed chunks */
              }
            }
          }

          setMessages((prev) =>
            prev.map((m) => (m.id === assistantMsg.id ? { ...m, status: 'done' } : m))
          );
        }
      } catch {
        await streamDemoResponse(assistantMsg.id, (accumulated, citations, done) => {
          setMessages((prev) =>
            prev.map((m) =>
              m.id === assistantMsg.id
                ? {
                    ...m,
                    content: accumulated,
                    citations,
                    status: done ? 'done' : 'streaming',
                    isDemo: true,
                  }
                : m
            )
          );
        });
      } finally {
        setIsLoading(false);
      }
    },
    [input, isLoading]
  );

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const stopGeneration = () => {
    abortRef.current = true;
    setIsLoading(false);
    setMessages((prev) =>
      prev.map((m) => (m.status === 'streaming' ? { ...m, status: 'done' } : m))
    );
  };

  return (
    <div className="flex h-full flex-col bg-neutral-50 dark:bg-neutral-950">
      <div className="flex-1 overflow-y-auto">
        {messages.length === 0 ? (
          <EmptyState onPromptClick={(t) => sendMessage(t)} />
        ) : (
          <div className="mx-auto max-w-3xl py-4 sm:py-6">
            {messages.map((msg, idx) => (
              <MessageBubble key={msg.id} message={msg} isLast={idx === messages.length - 1} />
            ))}
            {isLoading && messages[messages.length - 1]?.status !== 'streaming' && (
              <TypingIndicator />
            )}
            <motion.div ref={bottomRef} layout />
          </div>
        )}
      </div>

      <div className="border-t border-neutral-200 bg-white px-4 py-4 dark:border-neutral-800 dark:bg-neutral-900">
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="mx-auto max-w-3xl"
        >
          <div className="relative flex items-end gap-2 rounded-2xl border border-neutral-200 bg-white px-4 py-3 shadow-sm transition-colors duration-200 focus-within:border-primary-400 dark:border-neutral-700 dark:bg-neutral-800 dark:focus-within:border-primary-600">
            <textarea
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Tanyakan tentang regulasi MBG, validasi menu, atau cari supplier..."
              rows={1}
              className="flex-1 resize-none bg-transparent text-sm leading-relaxed text-neutral-900 outline-none placeholder:text-neutral-400 dark:text-neutral-100 dark:placeholder:text-neutral-500"
              style={{ maxHeight: '160px' }}
            />
            <button
              type="button"
              onClick={() => (isLoading ? stopGeneration() : sendMessage())}
              disabled={!isLoading && !input.trim()}
              className={cn(
                'flex h-8 w-8 shrink-0 items-center justify-center rounded-xl transition-all duration-150',
                (input.trim() || isLoading) &&
                  'bg-primary-500 text-white shadow-sm shadow-primary-500/30 hover:bg-primary-600 active:scale-90',
                !input.trim() &&
                  !isLoading &&
                  'cursor-not-allowed bg-neutral-100 text-neutral-400 dark:bg-neutral-700 dark:text-neutral-500'
              )}
            >
              {isLoading ? <StopCircle className="h-4 w-4" /> : <Send className="h-4 w-4" />}
            </button>
          </div>
          <p className="mt-2 text-center text-[11px] text-neutral-400 dark:text-neutral-600">
            ChatMBG dapat membuat kesalahan. Selalu verifikasi dengan regulasi asli.
          </p>
        </motion.div>
      </div>
    </div>
  );
}
