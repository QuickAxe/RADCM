# from django.http import JsonResponse
from django.db import connection

from rest_framework.decorators import api_view
from rest_framework.response import Response

from path import spatial_database_queries as sp


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
    
    data = sp.get_path_by_longlat(long1, lat1, long2, lat2)
    return Response(data)
    
