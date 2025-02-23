from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response

@api_view(["POST"])
def anomaly_data_collection_view(request):
    try:
        # Extract anomaly data from request body
        anomaly_data = request.data.get("anomaly_data")

        # Validate that anomaly_data is a dictionary
        if not isinstance(anomaly_data, dict):
            return Response(
                {"error": "Invalid format. anomaly_data should be a dictionary of anomalies."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Process each anomaly
        for key, anomaly in anomaly_data.items():
            if not isinstance(anomaly, dict):
                return Response(
                    {"error": f"Each anomaly entry must be a dictionary. Error in {key}"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Extract fields
            latitude = anomaly.get("latitude")
            longitude = anomaly.get("longitude")
            window = anomaly.get("window")

            # Validate latitude and longitude
            try:
                latitude, longitude = float(latitude), float(longitude)
                if not (-90 <= latitude <= 90) or not (-180 <= longitude <= 180):
                    raise ValueError
            except (TypeError, ValueError):
                return Response(
                    {"error": f"Invalid latitude/longitude in anomaly {key}"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Validate window is a list of lists
            if not isinstance(window, list) or not all(isinstance(row, list) for row in window):
                return Response(
                    {"error": f"Invalid window format in anomaly {key}. Must be a list of lists."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Validate that the window has exactly 200 sublists
            if len(window) != 200:
                return Response(
                    {"error": f"Invalid window length in anomaly {key}. Must contain exactly 200 sublists, but got {len(window)}."},
                    status=status.HTTP_400_BAD_REQUEST
                )

        # Success response
        return Response(
            {
                "message": "Anomaly data received successfully!",
                "processed_data": anomaly_data  # You can modify this to store/process as needed
            },
            status=status.HTTP_200_OK
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)