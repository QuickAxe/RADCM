from django.db import connection, DatabaseError
from math import pi
from itertools import starmap


def get_nodes_from_longlat(lng1: float, lat1: float, lng2: float, lat2: float) -> tuple[int, int]:
    with connection.cursor() as cursor:
        
        query = '''WITH source_id as (with s as (select %s as long , %s as lat)
        select id from nodes as n,s
        WHERE ST_DWithin(geom, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
		AND EXISTS (
		SELECT 1 FROM edges AS e WHERE (e.source = n.id or e.target = n.id)
		AND ST_DWithin(n.geom, e.geom_way, 0.0001)
		AND ST_DWithin(e.geom_way, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
		AND (e.car_forward <> 'Forbidden' OR e.car_backward <> 'Forbidden')
		)
            order by (
            select ST_DISTANCE(
            geom,
            ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326)
            )
        )
		
        limit 1),				
        target_id as (with s as (select %s as long , %s as lat)
        select id from nodes AS n,s
        WHERE ST_DWithin(geom, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
		AND EXISTS (
		SELECT 1 FROM edges AS e WHERE (e.source = n.id or e.target = n.id) 
		AND ST_DWithin(n.geom, e.geom_way, 0.0001)
		AND ST_DWithin(e.geom_way, ST_SetSRID(ST_MAKEPOINT(s.long , s.lat), 4326), 0.05)
		AND (e.car_forward <> 'Forbidden' OR e.car_backward <> 'Forbidden')
		)
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
    long_: float, lat_: float, distance_in_degrees: float = 0.4
)->list[dict]:
    # If you can't run this, check Server/anomalies
    #  - migrations.sql       # Update the database schema
    #  - random_anomalies.sql # Add random fake data
    with connection.cursor() as cursor:
        query = """SELECT 
                        json_agg(json_build_object(
	                'longitude',ST_X(p_geom),
	                'latitude', ST_Y(p_geom),
	                'category', a_type,
                    'anomaly_id', unique_id
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
                    'WITH box as (SELECT ST_Expand(ST_Extent(geom_way), 0.1) as box from edges as b
	                WHERE b.source = '||(select id from source_id)|| ' OR b.source= '||(select id from target_id)||'  
                        OR b.target = '||(select id from source_id)|| ' OR b.target= '||(select id from target_id)||'
                        )
                    SELECT id_new as id, source, target, 
                    CASE 
                        WHEN e.car_forward <> ''Forbidden'' then length::double precision 
                        ELSE -1 
                    END as cost, 
                    CASE 
                        WHEN e.car_backward <> ''Forbidden'' then length::double precision 
                        ELSE -1 
                    END as reverse_cost 
                    FROM public.edges as e, box
	                 WHERE e.geom_way && box.box
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

def get_path_by_nodeid(source_id:int,target_id:int) -> list[list[dict]]:
    with connection.cursor() as cursor:
        # If you get an error her about geom in nodes or geom_way in edges check ./migrations.sql
        cursor.execute(
            """WITH input as (SELECT %s AS source_id, %s AS target_id),
                box AS (SELECT ST_Expand(ST_Extent(geom_way), 0.1) as box from edges as b, input
                    WHERE b.source = input.source_id OR b.source = input.target_id
                    OR b.target = input.source_id OR b.target= input.target_id
                ),
                normal_dr as (
                select * FROM pgr_dijkstra(
                    'SELECT id_new as id, source, target, 
                CASE 
                    WHEN e.car_forward <> ''Forbidden'' then length::double precision 
                    ELSE -1 
                END as cost, 
                CASE 
                    WHEN e.car_backward <> ''Forbidden'' then length::double precision 
                    ELSE -1 
                END as reverse_cost  
                FROM public.edges as e
                WHERE e.geom_way && ST_GeomFromText(''' ||(select ST_AsText(box) from box)|| ''', 4326)
                    ',
                    (select source_id from input),
                    (select target_id from input))
                    ),
                plusfive_dr as (
                select * FROM pgr_dijkstra(
                    'SELECT id_new as id, source, target, 
                CASE 
                            WHEN e.car_forward <> ''Forbidden'' THEN length::double precision + 5*(
                                SELECT COUNT(*) FROM mv_clustered_anomalies AS ca 
                                WHERE ST_DWithin(e.geom_way, ca.p_geom, 0.001) 
                                AND ca.edge_id = e.id_new
                            )
                            ELSE -1 
                        END AS cost, 
                        CASE 
                            WHEN e.car_backward <> ''Forbidden'' THEN length::double precision + 5*(
                                SELECT COUNT(*) FROM mv_clustered_anomalies AS ca 
                                WHERE ST_DWithin(e.geom_way, ca.p_geom, 0.001) 
                                AND ca.edge_id = e.id_new
                            )
                            ELSE -1 
                        END AS reverse_cost  
                FROM public.edges as e
                WHERE e.geom_way && ST_GeomFromText(''' ||(select ST_AsText(box) from box)|| ''', 4326)
                    ',
                    (select source_id from input),
                    (select target_id from input))
                    )

                SELECT
                json_agg(step) 
                FROM
                (
                SELECT 
                json_build_object(
                    'path_seq', dr.path_seq,
                    'node_id', dr.node,
                    'polyline',
                    ST_AsEncodedPolyline(
                        CASE WHEN dr.node = e.source THEN e.geom_way ELSE ST_Reverse(e.geom_way) END
                        , 5),
                    'cost', 
                    e.length::double precision ,
                    'agg_cost', 
                    SUM(e.length::double precision ) OVER (ORDER BY dr.path_seq),
                    'WKT', 
                    CASE WHEN dr.node = e.source THEN e.wkt ELSE ST_AsText(ST_Reverse(e.geom_way)) END, 
                    'maneuver', json_build_object(
                    'bearing1',
                    CASE WHEN dr.node = e.source 
                        THEN ST_Azimuth(ST_PointN(e.wkt, 1), ST_PointN(e.wkt, 2))
                        ELSE ST_Azimuth(ST_PointN(e.wkt, -1), ST_PointN(e.wkt, -2))
                    END,
                    'bearing2',
                    CASE WHEN dr.node = e.source 
                        THEN ST_Azimuth(ST_PointN(e.wkt, -1), ST_PointN(e.wkt, -2))
                        ELSE ST_Azimuth(ST_PointN(e.wkt, 1), ST_PointN(e.wkt, 2))
                    END
                    ),
                    'anomalies',
                    ( SELECT json_agg(json_build_object('longitude',ST_X(p_geom),'latitude', ST_Y(p_geom),'category', a_type,'anomaly_id', unique_id))
                    FROM mv_clustered_anomalies AS ca
                    WHERE 
                    ST_DWithin(
                    e.geom_way, ca.p_geom 
                    , 0.001) 
                    AND 
                    ca.edge_id = e.id_new
                    ) 	
                ) as step
                from 
                normal_dr AS dr, edges  AS e where e.id_new = dr.edge 
                order by path_seq asc
                )

                UNION ALL
                SELECT
                json_agg(step) 
                FROM
                (
                SELECT 
                json_build_object(
                    'path_seq', dr.path_seq,
                    'node_id', dr.node,
                    'polyline',
                    ST_AsEncodedPolyline(
                        CASE WHEN dr.node = e.source THEN e.geom_way ELSE ST_Reverse(e.geom_way) END
                        , 5),
                    'cost', 
                    e.length::double precision ,
                    'agg_cost', 
                    SUM(e.length::double precision ) OVER (ORDER BY dr.path_seq),
                    'WKT', 
                    CASE WHEN dr.node = e.source THEN e.wkt ELSE ST_AsText(ST_Reverse(e.geom_way)) END, 
                    'maneuver', json_build_object(
                    'bearing1',
                    CASE WHEN dr.node = e.source 
                        THEN ST_Azimuth(ST_PointN(e.wkt, 1), ST_PointN(e.wkt, 2))
                        ELSE ST_Azimuth(ST_PointN(e.wkt, -1), ST_PointN(e.wkt, -2))
                    END,
                    'bearing2',
                    CASE WHEN dr.node = e.source 
                        THEN ST_Azimuth(ST_PointN(e.wkt, -1), ST_PointN(e.wkt, -2))
                        ELSE ST_Azimuth(ST_PointN(e.wkt, 1), ST_PointN(e.wkt, 2))
                    END
                    ),
                    'anomalies',
                    ( SELECT json_agg(json_build_object('longitude',ST_X(p_geom),'latitude', ST_Y(p_geom),'category', a_type))
                    FROM mv_clustered_anomalies AS ca
                    WHERE 
                    ST_DWithin(
                    e.geom_way, ca.p_geom 
                    , 0.001) 
                    AND 
                    ca.edge_id = e.id_new
                    ) 	
                ) as step
                from 
                plusfive_dr AS dr, edges  AS e where e.id_new = dr.edge 
                order by path_seq asc
                )

                ;
                    """,
            [source_id, target_id],
        )
        # print("HERE")
        # Fetch the results
        results = cursor.fetchall()
        if (
            not results
            or not results[0]
            or not results[1]
            or not results[0][0]  # Don't know if these are necessary
            or not results[1][0]
        ):
            raise ValueError("No entry found in the database")
        
        def add_turn(array_of_dicts: list[dict]):

            for i in range(1, len(array_of_dicts)):
                curr_dict = array_of_dicts[i]
                prev_dict = array_of_dicts[i-1]
                turn_angle = (curr_dict["maneuver"]["bearing1"] - prev_dict["maneuver"]["bearing2"]) %( 2 * pi)
                
                if turn_angle <= (1 - 1 / 4) * pi:
                    curr_dict["maneuver"]["turn_direction"] = "LEFT"
                elif turn_angle <= (1 - 1 / 8) * pi:
                    curr_dict["maneuver"]["turn_direction"] = "SLIGHTLY LEFT"
                elif turn_angle <= (1 + 1 / 8) * pi:
                    curr_dict["maneuver"]["turn_direction"] = "STRAIGHT"
                elif turn_angle <= (1 + 1 / 4) * pi:
                    curr_dict["maneuver"]["turn_direction"] = "SLIGHTLY RIGHT"
                elif turn_angle <= 2 * pi:
                    curr_dict["maneuver"]["turn_direction"] = "RIGHT"

        results = [results[0][0], results[1][0]]
        if not routes_are_different(results[0], results[1]):
            print("Same route")
            results = [results[0]]
        for arr in results:
            add_turn(arr)

        return results


def routes_are_different(route1: list, route2: list) -> bool:
    if len(route1) != len(route2):
        return True
    return any(starmap(lambda x, y: x["node_id"] != y["node_id"], zip(route1, route2)))


# r1 = [
#     {"node_id": 1},
#     {"node_id": 2},
# ]
# r2 = [
#     {"node_id": 1},
#     {"node_id": 2},
# ]
# r3 = [
#     {"node_id": 1},
#     {"node_id": 2},
#     {"node_id": 3},
# ]
# r4 = [
#     {"node_id": 1},
#     {"node_id": 2},
#     {"node_id": 4},
# ]

# if not routes_are_different(r1, r2):
#     print("Pass")
# else:
#     print("Fail")

# if routes_are_different(r1, r3):
#     print("Pass")
# else:
#     print("Fail")
# if routes_are_different(r3, r4):
#     print("Pass")
# else:
#     print("Fail")


def add_anomaly(longitude, latitude, a_type,confidence):
    with connection.cursor() as cursor:
        query = """INSERT INTO public.potential_anomaly(
                    longitude, latitude, a_type, confidence)
                    VALUES (%s, %s, %s, %s);"""
        cursor.execute(query, [longitude, latitude, a_type,confidence])
# List of  (longitude, latitude, a_type,confidence)
def add_anomaly_array(arr: list[tuple[float, float, str, float]]):
    with connection.cursor() as cursor:
        query = """INSERT INTO public.potential_anomaly(
                    longitude, latitude, a_type, confidence)
                    VALUES (%s, %s, %s, %s);"""
        cursor.executemany(query, arr)

def get_ids_of_potential_anomalies(longitude:float, latitude:float, cluster_id:int):
    with connection.cursor() as cursor:
        query = """
                WITH input as (SELECT %s as lng, %s lat, %s as cid)
                SELECT point_ids
                FROM mv_clustered_anomalies, input
                WHERE 
                    ST_DWithin(
                        p_geom, 
                        st_setsrid(st_makepoint(input.lng, input.lat),4326),
                        0.01)
                    AND unique_id = input.cid
                ORDER BY (
                    SELECT ST_DISTANCE(p_geom, ST_SetSRID(ST_MAKEPOINT(input.lng , input.lat), 4326))
            ) 
            LIMIT 1
                ;"""
        cursor.execute(query, [longitude, latitude, cluster_id])       
        results = cursor.fetchone()
        
        return results[0]
    
def delete_from_potential_anomaly(ids: list[int]):
    with connection.cursor() as cursor:
        if not isinstance(ids, list) or not all(int(x) for x in ids):
            raise ValueError
        placeholders = ', '.join(['%s'] * len(ids))
        query = f"DELETE FROM potential_anomaly WHERE id IN ({placeholders})"
        try:
            cursor.execute(query, ids)
        except DatabaseError as e:
            print(str(e))
