from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response


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

        #  <---------------------------------------------------------------------------------- modify this
        # Shantanu shall add a function call here
        # the function will return a list of anomalies (list of dictionaires - check below) in a region around (lattitude, longitude)

        # list of dictionaries for the content (remove hardcoded content and assign it accordingly)
        anomalies = [
            {
                "latitude": 15.591181864471721,
                "longitude": 73.81062185333096,
                "category": "Speedbreaker",
            },
            {
                "latitude": 15.588822298730122,
                "longitude": 73.81307154458827,
                "category": "Rumbler",
            },
            {
                "latitude": 15.593873211033117,
                "longitude": 73.81406673161777,
                "category": "Obstacle",
            },
            {
                "latitude": 15.594893209859874,
                "longitude": 73.80957563101596,
                "category": "Speedbreaker",
            },
        ]
        #  <---------------------------------------------------------------------------------- /modify this

        # Success response
        print("go sing a song.. it works")

        return Response(
            {"message": "Coordinates received successfully!", "anomalies": anomalies},
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
        # the function will return a list of routes (list of dictionaires - check below) from (lattitudeStart, longitudeStart) to (lattitudeEnd, longitudeEnd)

        # list of dictionaries for the content (remove hardcoded content and assign it accordingly)
        routes = [
            {
                "route": 1,
            },
            {
                "route": 2,
            },
        ]
        #  <---------------------------------------------------------------------------------- /modify this

        # Success response
        print("go sing a song.. it works")

        return Response(
            {
                "message": "Coordinates received successfully!",
                "routes": routes,
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
