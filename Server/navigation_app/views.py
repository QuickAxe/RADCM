from rest_framework.decorators import api_view, throttle_classes
from rest_framework.throttling import UserRateThrottle, AnonRateThrottle
from rest_framework import status
from rest_framework.response import Response
from django.core.cache import cache
from django.db import connection

from path import spatial_database_queries as sp


@api_view(["GET"])
@throttle_classes([UserRateThrottle, AnonRateThrottle])
def anomalies_in_region_view(request):
    try:
        # Extract latitude and longitude from request body (expects JSON)
        latitude = request.query_params.get("latitude")
        longitude = request.query_params.get("longitude")

        try:
            radius = request.query_params.get("radius")
            if radius is None:
                raise ValueError
            radius = float(radius)
            if radius < 0.001:
                raise ValueError
        except ValueError:
            radius = 0.4
        # Check if lat lon has some content or not
        if latitude is None or longitude is None:
            return Response(
                {"error": "Latitude and longitude are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Ensure lat lon are floats
        try:
            latitude = float(latitude)
            longitude = float(longitude)
        except ValueError:
            return Response(
                {"error": "Latitude and longitude must be valid numbers."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Check valid latitude (-90 to 90) and longitude (-180 to 180)
        if not (-90 <= latitude <= 90) or not (-180 <= longitude <= 180):
            return Response(
                {"error": "Invalid latitude or longitude values."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        anomalies_data = sp.get_anomalies_by_longlat(longitude, latitude, radius)

        return Response(
            {
                "message": "Coordinates received successfully!",
                "anomalies": anomalies_data,
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
@throttle_classes([UserRateThrottle, AnonRateThrottle])
def routes_view(request):
    try:
        # Extract start and end coordinates from request data
        latitudeStart = request.query_params.get("latitudeStart")
        longitudeStart = request.query_params.get("longitudeStart")

        latitudeEnd = request.query_params.get("latitudeEnd")
        longitudeEnd = request.query_params.get("longitudeEnd")

        # Validate that all required fields are present
        if None in (latitudeStart, longitudeStart, latitudeEnd, longitudeEnd):
            return Response(
                {"error": "Both start and end latitude/longitude are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Ensure latitude and longitude are valid floats
        try:
            latitudeStart = float(latitudeStart)
            longitudeStart = float(longitudeStart)
            latitudeEnd = float(latitudeEnd)
            longitudeEnd = float(longitudeEnd)
        except ValueError:
            return Response(
                {"error": "Latitude and longitude must be valid numbers."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Validate latitude (-90 to 90) and longitude (-180 to 180)
        for lat, lon in [(latitudeStart, longitudeStart), (latitudeEnd, longitudeEnd)]:
            if not (-90 <= lat <= 90) or not (-180 <= lon <= 180):
                return Response(
                    {"error": "Invalid latitude or longitude values."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        # get nodes for corresponding (lon, lat) pairs
        node1, node2 = sp.get_nodes_from_longlat(
            longitudeStart,
            latitudeStart,
            longitudeEnd,
            latitudeEnd,
        )

        # check cache
        key = str(node1) + "_" + str(node2)
        value = cache.get(key)

        routes = value
        if not routes:
            routes = sp.get_path_by_nodeid(node1, node2)
            cache.set(key, routes, timeout=60 * 10)
            print("stored route in cache - got value from db query")
        else:
            print("retrived route from redis cache")

        return Response(
            {
                "message": "Coordinates received successfully!",
                "routes": routes,
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
