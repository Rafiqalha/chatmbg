/**
 * Type declarations for Supabase Edge Functions (Deno runtime).
 * This file provides ambient types so the IDE doesn't flag Deno-specific
 * APIs and URL-based module imports as errors.
 */

// ── Deno namespace ───────────────────────────────────────────────────────────
declare namespace Deno {
  export interface Env {
    get(key: string): string | undefined;
    set(key: string, value: string): void;
    delete(key: string): void;
    has(key: string): boolean;
    toObject(): Record<string, string>;
  }
  export const env: Env;
}

// ── URL-based module declarations ────────────────────────────────────────────
declare module 'https://deno.land/std@0.168.0/http/server.ts' {
  export function serve(handler: (req: Request) => Response | Promise<Response>): void;
}

declare module 'https://esm.sh/@supabase/supabase-js@2' {
  export function createClient(
    supabaseUrl: string,
    supabaseKey: string,
    options?: Record<string, unknown>
  ): {
    rpc: (fn: string, params: Record<string, unknown>) => Promise<{ data: any; error: any }>;
    from: (table: string) => any;
    auth: any;
    storage: any;
    [key: string]: any;
  };
}
