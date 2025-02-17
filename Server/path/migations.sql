-- These columns and indexes need to be added to the database 
-- for the current version of the server to work

-- Run this in psql or pgAdmin 

ALTER TABLE IF EXISTS public.nodes DROP COLUMN IF EXISTS geom;

ALTER TABLE IF EXISTS public.nodes
    ADD COLUMN geom geometry GENERATED ALWAYS AS (st_setsrid(st_makepoint(longitude, latitude), 4326)) STORED;

DROP INDEX IF EXISTS public.nodes_geom_idx;

CREATE INDEX IF NOT EXISTS nodes_geom_idx
    ON public.nodes USING gist
    (geom)
    TABLESPACE pg_default;


ALTER TABLE IF EXISTS public.edges DROP COLUMN IF EXISTS geom_way;

ALTER TABLE IF EXISTS public.edges
    ADD COLUMN geom_way geometry GENERATED ALWAYS AS (st_geomfromtext(wkt, 4269)) STORED;

DROP INDEX IF EXISTS public.edges_geom_way_idx;

CREATE INDEX IF NOT EXISTS edges_geom_way_idx
    ON public.edges USING gist
    (geom_way)
    TABLESPACE pg_default;
