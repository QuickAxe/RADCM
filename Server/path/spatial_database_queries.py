from django.db import connection

def get_nodes_from_longlat(lng1: float, lat1: float, lng2: float, lat2: float) -> tuple[int, int]:
    with connection.cursor() as cursor:
        
        query = '''WITH source_id as (with s as (select %s as long , %s as lat)
        select id from nodes,s
        WHERE ST_DWithin(geom, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
            order by (
            select ST_DISTANCE(
            geom,
            ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326)
            )
        )
        limit 1),				
        target_id as (with s as (select %s as long , %s as lat)
        select id from nodes,s
        WHERE ST_DWithin(geom, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
            order by (
            select ST_DISTANCE(
            geom,
            ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326)
            )
        )
        limit 1)
        SELECT
        source_id.id, target_id.id
        FROM source_id, target_id'''
        
        cursor.execute(query, [lng1, lat1, lng2, lat2, ])
        result = cursor.fetchone()
        if not result or not result[0] or not result[1]:
            raise ValueError("No entry found in the database")
        return result
        
def get_anomalies_by_longlat(
    long_: float, lat_: float, distance_in_degrees: float = 0.01
)->list[dict]:
    # If you can't run this, check Server/anomalies
    #  - migrations.sql       # Update the database schema
    #  - random_anomalies.sql # Add random fake data
    with connection.cursor() as cursor:
        query = """SELECT 
                        json_agg(json_build_object(
	                'longitude',ST_X(p_geom),
	                'latitude', ST_Y(p_geom),
	                'category', a_type
	                )  )
                FROM mv_clustered_anomalies
                WHERE 
                    ST_DWithin(
                        p_geom, 
                        st_setsrid(
                            st_makepoint(%s, %s), 
                                    4326),
                        %s)
                ;"""
        cursor.execute(query, [long_, lat_, distance_in_degrees])

        # Result processing needed for non json sql query
        # results = [
        #     {
        #         "longitude": tup[0],
        #         "latitude": tup[1],
        #         "category": tup[2],
        #     }
        #     for tup in results
        # ]
        # print(type(results), type(results[0]))

        # Note: query is written in a way to return a json array.
        results = cursor.fetchone()
        # Note: Query returns 1 item which is a json array.
        #       destructing it here
        # print(results[0])
        return results[0]

def get_path_by_longlat(long1:float, lat1:float, long2:float, lat2:float):
    with connection.cursor() as cursor:
        # If you get an error her about geom in nodes or geom_way in edges check ./migrations.sql
        cursor.execute(
            """WITH source_id as (with s as (select %s as long , %s as lat)
                select id from nodes,s
                WHERE ST_DWithin(geom, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
                	order by (
                    select ST_DISTANCE(
                    geom,
                    ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326)
                    )
                )
                limit 1),
                target_id as (with s as (select %s as long , %s as lat)
                select id from nodes,s
                WHERE ST_DWithin(geom, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
                	order by (
                    select ST_DISTANCE(
                    geom,
                    ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326)
                    )
                )
                limit 1),
                dr as (
                select * FROM pgr_dijkstra(
                    'SELECT id_new as id, source, target, length::double precision as cost FROM public.edges as e, 
	                (SELECT ST_Expand(ST_Extent(geom_way), 0.1) as box from edges as b
	                WHERE b.source = '||(select id from source_id)|| '
	                OR b.target= '||(select id from target_id)||'  )as box WHERE e.geom_way && box.box
                    ',
                	(select id from source_id),
                	(select id from target_id))
                	)
                select dr.*, e.wkt from dr, edges e where e.id_new = dr.edge order by seq, path_seq asc;
            """,
            [long1, lat1, long2, lat2],
        )

        # Fetch the results
        results = cursor.fetchall()
        return results

def get_path_by_nodeid(source_id:int,target_id:int):
    with connection.cursor() as cursor:
        # If you get an error her about geom in nodes or geom_way in edges check ./migrations.sql
        cursor.execute(
            """WITH input as (SELECT %s AS source_id, %s AS target_id),
                dr as (
                select * FROM pgr_dijkstra(
                	'SELECT id_new as id, source, target, length::double precision as cost FROM public.edges as e, 
                	(SELECT ST_Expand(ST_Extent(geom_way), 0.1) as box from edges as b
                	WHERE b.source = '||(select source_id from input)|| '
                	OR b.target= '||(select target_id from input)||'  )as box WHERE e.geom_way && box.box
                	',
                	(select source_id from input),
                	(select target_id from input))
                	)
                SELECT
                json_agg(step) 
                FROM
                (SELECT 
                json_build_object(
                	'path_seq', dr.path_seq,
                	'polyline',
                	ST_AsEncodedPolyline(e.geom_way, 5),
                	'cost', 
                	dr.cost,
                	'agg_cost', 
                	dr.agg_cost,
                	'WKT', 
                	e.wkt, 
                	'maneuver', json_build_object(
                	'bearing1',ST_Azimuth(ST_PointN(e.geom_way, 1),  ST_PointN(e.geom_way, 2)),
                	'bearing2',ST_Azimuth(ST_PointN(e.geom_way, -1), ST_PointN(e.geom_way, -2))
                	)
                ) as step
                from 
                dr, edges 
                AS e where e.id_new = dr.edge 
                order by path_seq asc
                )
                ;
            """,
            [source_id, target_id],
        )

        # Fetch the results
        results = cursor.fetchone()
        print(type(results))
        return results[0]
