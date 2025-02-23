-- potential_anomaly

DROP TYPE IF EXISTS public.anomaly_type;

CREATE TYPE public.anomaly_type AS ENUM
    ('Unknown', 'Pothole', 'SpeedBreaker', 'Rumbler', 'Cracks');

DROP TABLE IF EXISTS public.potential_anomaly;

CREATE TABLE IF NOT EXISTS public.potential_anomaly
(
    id bigint NOT NULL,
    longitude double precision,
    latitude double precision,
    a_type anomaly_type,
    confidence double precision,
    geom geometry GENERATED ALWAYS AS (st_setsrid(st_makepoint(longitude, latitude), 4326)) STORED,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT p_anom_pk PRIMARY KEY (id)
)

-- mv_clustered_anomalies

DROP MATERIALIZED VIEW IF EXISTS public.mv_clustered_anomalies;



CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_clustered_anomalies
TABLESPACE pg_default
AS
 WITH clustered_anomalies AS (
         SELECT potential_anomaly.id,
            potential_anomaly.geom,
            potential_anomaly.a_type,
            potential_anomaly.confidence,
            st_clusterwithinwin(potential_anomaly.geom, 0.0002::double precision) OVER () AS cluster_id
           FROM potential_anomaly
        )
 SELECT row_number() OVER () AS unique_id,
    sum(confidence) AS total_confidence,
    a_type,
    array_agg(id) AS point_ids,
    count(id) AS point_count,
    ( SELECT st_lineinterpolatepoint(e.geom_way, st_linelocatepoint(e.geom_way, st_centroid(st_collect(clustered_anomalies.geom)))) AS st_lineinterpolatepoint
           FROM edges e
          WHERE st_dwithin(e.geom_way, st_centroid(st_collect(clustered_anomalies.geom)), 0.002::double precision)
          ORDER BY (st_distance(e.geom_way, st_centroid(st_collect(clustered_anomalies.geom))))
         LIMIT 1) AS p_geom,
    ( SELECT e.id_new
           FROM edges e
          WHERE st_dwithin(e.geom_way, st_centroid(st_collect(clustered_anomalies.geom)), 0.002::double precision)
          ORDER BY (st_distance(e.geom_way, st_centroid(st_collect(clustered_anomalies.geom))))
         LIMIT 1) AS edge_id
   FROM clustered_anomalies
  GROUP BY cluster_id, a_type
WITH DATA;

ALTER TABLE IF EXISTS public.mv_clustered_anomalies
    OWNER TO postgres;


CREATE INDEX mv_p_geom_idx
    ON public.mv_clustered_anomalies USING gist
    (p_geom)
    TABLESPACE pg_default;


-- Trigger to refresh the view

CREATE OR REPLACE FUNCTION refresh_mv_clustered_anomalies()
RETURNS TRIGGER AS $$
BEGIN    
    REFRESH MATERIALIZED VIEW mv_clustered_anomalies;
    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_mv_clustered_anomalies
AFTER INSERT OR UPDATE OR DELETE ON potential_anomaly
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_mv_clustered_anomalies();