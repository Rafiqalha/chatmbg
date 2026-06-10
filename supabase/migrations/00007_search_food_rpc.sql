-- Pencarian TKPI by nama (trigram + FTS)
CREATE OR REPLACE FUNCTION search_food_by_name(
  query TEXT,
  limit_n INT DEFAULT 5
)
RETURNS SETOF food_items AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM food_items f
  WHERE
    f.nama_pangan ILIKE '%' || query || '%'
    OR query = ANY(f.nama_alias)
    OR f.fts_vector @@ websearch_to_tsquery('indonesian', query)
  ORDER BY
    similarity(f.nama_pangan, query) DESC NULLS LAST,
    f.nama_pangan
  LIMIT limit_n;
END;
$$ LANGUAGE plpgsql STABLE;
