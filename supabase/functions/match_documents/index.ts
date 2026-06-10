import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { query_embedding, match_count = 5, filter } = await req.json();

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Hybrid search: vector similarity + full-text search
    const { data: vectorResults, error: vectorError } = await supabaseClient.rpc(
      'match_knowledge_chunks',
      {
        query_embedding,
        match_threshold: 0.7,
        match_count:     match_count + 5,  // over-fetch for re-ranking
        filter:          filter ?? {},
      }
    );

    if (vectorError) throw vectorError;

    // Re-rank by recency (newer regulations weighted higher)
    const reranked = (vectorResults ?? [])
      .sort((a: any, b: any) => {
        const recencyWeight = 0.2;
        const simWeight = 0.8;
        const scoreA = simWeight * a.similarity + recencyWeight * (a.is_current_regulation ? 1 : 0.5);
        const scoreB = simWeight * b.similarity + recencyWeight * (b.is_current_regulation ? 1 : 0.5);
        return scoreB - scoreA;
      })
      .slice(0, match_count);

    return new Response(JSON.stringify(reranked), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
