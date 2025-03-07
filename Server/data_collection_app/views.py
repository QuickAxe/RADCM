from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response

from SensorModel.inference import predictAnomalyClass

# Response data format:
# {
#     "source": "mobile",
#     "anomaly_data": [
#         {
#             "latitude": 15.600218,
#             "longitude": 73.826060,
#             "window": [[1.2, 2.3, 4.2], .....,  [5.6, 7.8, 9.0]],
#         },
#         {
#             "latitude": 15.600219,
#             "longitude": 73.826061,
#             "window": [[2.3, 3.4, 5.6], ......,  [6.7, 8.9, 1.2]],
#         },
#     ]
# }
#
# Note: it is enforced that windwo should contain 200 sublists.. bcoz thats what it should
# source - "mobile" / "jimmy" 

# jimmy => Jiggle Intensity Mpu Module Yes


@api_view(["POST"])
def anomaly_sensor_data_collection_view(request):
    try:
        # Extract anomaly data from request body
        anomaly_data = request.data.get("anomaly_data")
        source = request.data.get("source")

        # Validate that anomaly_data is a list
        if not isinstance(anomaly_data, list):
            return Response(
                {
                    "error": "Invalid format. anomaly_data should be a list of anomalies."
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        # a list to store all anomalies, and only anomaly data, to send to the model
        # the first dim should be the number of anomalies in the list
        anomalyList = []
        
        # Process each anomaly
        for anomaly in anomaly_data:
            if not isinstance(anomaly, dict):
                return Response(
                    {
                        "error": "Each anomaly entry must be a dictionary."
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
                    {"error": f"Invalid latitude/longitude in anomaly"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Validate window is a list of lists
            if not isinstance(window, list) or not all(
                isinstance(row, list) for row in window
            ):
                return Response(
                    {
                        "error": f"Invalid window format in anomaly. Must be a list of lists."
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Validate that the window has exactly 200 sublists
            if len(window) != 200:
                return Response(
                    {
                        "error": f"Invalid window length in anomaly. Must contain exactly 200 sublists, but got {len(window)}."
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            anomalyList.append(window)

        
        #todo  <---------------------------------------------------------------------------------- modify this
        if source == "jimmy":
            print("recieved data from jimmy")
            # handle data from jimmy
        else:
            print("recieved data from mobile")
            # handle data from mobile      

        # send anomalyList to the model here.. 
        # the shape of anomaly list will be (no of anomalies, 200, 3)
        # the reason I'm sending them as batches and not one at a time is to possibly speed up inference
        # anomalyOutputs = predictAnomalyClass(anomalyList)

        # anomalyOutputs should be of the form:
        # [ (anomaly_1_CLass, confidence), (anomaly_2_Class, confidence), ...... ]
        # ugh look at me using snake case 
        # NOTE: the class here is an index of the class, use below reference to decode it, but in reverse:
        # classNames = {"Pothole": 0, "Breaker": 1, "Flat": 2}
        # NOTE: as of now, only the first two classes have been used

        # ! now add these to database, take care of the source (for the weights)
        # ! OUUU, what if... we scale the weights based on the confidence value??

        # ! ALSOO .. we should probably send the response before running inference for obvious reasons
        # running inference could take a long time, and would leave the client waiting for a response 
        # Success response
        return Response(
            {
                "message": "Anomaly sensor data received successfully!",
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(["POST"])
def anomaly_image_data_collection_view(request):
    try:
        return Response(
            {
                "message": "Anomaly image data received successfully!",
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
