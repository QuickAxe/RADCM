# from django.http import JsonResponse
from django.db import connection

from rest_framework.decorators import api_view
from rest_framework.response import Response


def get_path(long1, lat1, long2, lat2):
    with connection.cursor() as cursor:

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


@api_view(["GET"])
def my_view(request, coords):
    try:
        coords_pair = coords.split(";")
    except:
        if not coords_pair or  len(coords_pair) != 2:
            return Response(
                {"error": "Invalid coordinates. Need two coordinates separated by ';'"},
                status=400,
            )
    try:
        long_lat1 = coords_pair[0].split(",")
    except:
        if not long_lat1 or len(long_lat1) != 2:
            return Response(
                {
                    "error": "Invalid coordinates. Each coordinate must be separated by ','"
                },
                status=400,
            )
    try:
        long_lat2 = coords_pair[1].split(",")
    except:
        if not long_lat2 or len(long_lat2) != 2:
            return Response(
                {
                    "error": "Invalid coordinates. Each coordinate must be separated by ','"
                },
                status=400,
            )
        
    try:
        long1, lat1 = map(float, long_lat1)
        long2, lat2 = map(float, long_lat2)
    except ValueError:
        return Response(
            {
                "error": "Invalid coordinates. Coordinates must be floats",
            },
            status=400,
        )
    
    data = get_path(long1, lat1, long2, lat2)
    return Response(data)
    
