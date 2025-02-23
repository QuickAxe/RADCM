from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response

from django.db import connection


def get_anomalies_by_location(
    long_: float, lat_: float, distance_in_degrees: float = 0.01
):
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
        return results[0]


@api_view(["GET"])
def anomalies_in_region_view(request):
    try:
        # Extract latitude and longitude from request body (expects JSON)
        latitude = request.query_params.get("latitude")
        longitude = request.query_params.get("longitude")

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
        anomalies_data = get_anomalies_by_location(longitude, latitude)
        #  <---------------------------------------------------------------------------------- modify this
        # Shantanu shall add a function call here
        # the function will return a dictionary of anomalies (dictionary of dictionaires - check below) in a region around (lattitude, longitude)

        # dictionary of dictionaries for the content (remove hardcoded content and assign it accordingly)
        # anomalies_data = {
        #     "anomalies": [
        #         {
        #             "latitude": 15.591181864471721,
        #             "longitude": 73.81062185333096,
        #             "category": "Speedbreaker"
        #         },
        #         {
        #             "latitude": 15.588822298730122,
        #             "longitude": 73.81307154458827,
        #             "category": "Rumbler"
        #         },
        #         {
        #             "latitude": 15.593873211033117,
        #             "longitude": 73.81406673161777,
        #             "category": "Obstacle"
        #         },
        #         {
        #             "latitude": 15.594893209859874,
        #             "longitude": 73.80957563101596,
        #             "category": "Speedbreaker"
        #         }
        #     ]
        # }

        #  <---------------------------------------------------------------------------------- /modify this

        # Success response
        print("go sing a song.. it works")

        return Response(
            {"message": "Coordinates received successfully!", "anomalies": anomalies_data},
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(["GET"])
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


        #  <---------------------------------------------------------------------------------- modify this
        # Shantanu shall add a function call here
        # the function will return a dictionary of routes (dictionary of dictionaires - check below) from (lattitudeStart, longitudeStart) to (lattitudeEnd, longitudeEnd)

        # dictionary of dictionaries for the content (remove hardcoded content and assign it accordingly)
        routes_data = {
            "routes": [
                {
                    "route": 1
                },
                {
                    "route": 2
                }
            ]
        }
        #  <---------------------------------------------------------------------------------- /modify this

        # Success response
        print("go sing a song.. it works")

        return Response(
            {
                "message": "Coordinates received successfully!",
                "routes": routes_data,
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
