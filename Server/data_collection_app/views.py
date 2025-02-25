from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response

# Response data format:
# {
#     "source": "mobile",
#     "anomaly_data": {
#         "anomaly_1": {
#             "latitude": 15.591181864471721,
#             "longitude": 73.81062185333096,
#             "window": [[1.2, 2.3, 4.2], [5.6, 7.8, 9.0]],
#         },
#         "anomaly_2": {
#             "latitude": 15.588822298730122,
#             "longitude": 73.81307154458827,
#             "window": [[2.3, 3.4, 5.6], [6.7, 8.9, 1.2]],
#         },
#     }
# }
#
# Note: it is enforced that windwo should contain 200 sublists.. bcoz thats what it should
# source - "mobile" / "jimmy" 

# jimmy => Jiggle Intensity Mpu Module Yes


@api_view(["POST"])
def anomaly_data_collection_view(request):
    try:
        # Extract anomaly data from request body
        anomaly_data = request.data.get("anomaly_data")
        source = request.data.get("source")

        # Validate that anomaly_data is a dictionary
        if not isinstance(anomaly_data, dict):
            return Response(
                {
                    "error": "Invalid format. anomaly_data should be a dictionary of anomalies."
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Process each anomaly
        for key, anomaly in anomaly_data.items():
            if not isinstance(anomaly, dict):
                return Response(
                    {
                        "error": f"Each anomaly entry must be a dictionary. Error in {key}"
                    },
                    status=status.HTTP_400_BAD_REQUEST,
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
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Validate window is a list of lists
            if not isinstance(window, list) or not all(
                isinstance(row, list) for row in window
            ):
                return Response(
                    {
                        "error": f"Invalid window format in anomaly {key}. Must be a list of lists."
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Validate that the window has exactly 200 sublists
            if len(window) != 200:
                return Response(
                    {
                        "error": f"Invalid window length in anomaly {key}. Must contain exactly 200 sublists, but got {len(window)}."
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )
                
        
        #todo  <---------------------------------------------------------------------------------- modify this
        if source == "jimmy":
            print("recieved data from jimmy")
            # handle data from jimmy
        else:
            print("recieved data from mobile")
            # handle data from mobile

        # Someone will call a function that exposes the ML. model here..
        # it will take the anomalies.. classify them.. update the db.. and whatever

        #todo  <---------------------------------------------------------------------------------- /modify this

        # Success response
        return Response(
            {
                "message": "Anomaly data received successfully!",
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
