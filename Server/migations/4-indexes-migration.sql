CREATE UNIQUE INDEX IF NOT EXISTS edges_id_new_idx
    ON public.edges USING btree (id_new ASC NULLS LAST)
    WITH (deduplicate_items=True)
    TABLESPACE pg_default;



CREATE INDEX IF NOT EXISTS idx_edges_source_target
    ON public.edges USING btree (source ASC NULLS LAST, target ASC NULLS LAST)
    TABLESPACE pg_default;



CREATE INDEX IF NOT EXISTS mv_edge_idx
    ON public.mv_clustered_anomalies USING btree (edge_id ASC NULLS LAST)
    WITH (deduplicate_items=True)
    TABLESPACE pg_default;
