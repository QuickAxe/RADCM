# from django.http import JsonResponse
from django.db import connection

from rest_framework.decorators import api_view
from rest_framework.response import Response

def get_path(long1, lat1, long2, lat2):
    with connection.cursor() as cursor:
        
        cursor.execute('''WITH source_id as (select id from nodes 
                order by (
                	select ST_DISTANCE(
                		ST_SetSRID(ST_MAKEPOINT(longitude, latitude), 4326),
                		ST_SetSRID(ST_MAKEPOINT(%s, %s), 4326)
                	)
                )
                limit 1),
                target_id as (select id from nodes 
                order by (
                	select ST_DISTANCE(
                		ST_SetSRID(ST_MAKEPOINT(longitude, latitude), 4326),
                		ST_SetSRID(ST_MAKEPOINT(%s, %s), 4326)
                	)
                )
                limit 1),
                dr as (
                select * FROM pgr_dijkstra(
                    'SELECT id_new as id, source, target, length::double precision as cost FROM public.edges',
                	(select id from source_id),
                	(select id from target_id))
                	)
                select dr.*, e.wkt from dr, edges e where e.id_new = dr.edge order by seq, path_seq asc;
            ''', [long1, lat1, long2, lat2])

        # Fetch the results
        results = cursor.fetchall()
        return results

@api_view(['GET'])
def my_view(request,coords):
    try:
        coords_pair = coords.split(";")
        if len(coords_pair )!= 2:
            raise ValueError
        long_lat1 = coords_pair[0].split(',')
        if len(long_lat1) != 2:
            raise ValueError
        long_lat2 = coords_pair[1].split(',')
        if len(long_lat2) != 2:
            raise ValueError
        long1, lat1 = map(float, long_lat1)
        long2, lat2 = map(float, long_lat2)
        data = get_path(long1, lat1, long2, lat2) 
        return Response(data)
    except ValueError:
        return Response({'error': 'Invalid coordinates'}, status =400)