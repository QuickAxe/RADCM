from rest_framework.decorators import api_view, throttle_classes
from rest_framework.throttling import UserRateThrottle, AnonRateThrottle
from rest_framework import status
from rest_framework.response import Response
import os, uuid
import filetype
from django.conf import settings
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from SensorModel.inference import predictAnomalyClass
from VisionModel.inference import vision_predict_anomaly_class
from path import spatial_database_queries as sp

from celery import shared_task

import json
import uuid


@shared_task
def sensor_data_task(
    locations: list[tuple[float, float]], anomalies: list[list[float]]
):
    out = predictAnomalyClass(anomalies)
    # out is a list of tuples [[class, confidence]]
    # NOTE: the class here is an index of the class,
    #  use below reference to decode it, but in reverse:
    # classNames = {"Pothole": 0, "Breaker": 1, "Flat": 2}
    # NOTE: as of now, only the first two classes have been used
    #! Make sure that this mapping is consistent with whatever model is used
    reverse_map = ["Pothole", "SpeedBreaker", "Flat"]
    detected_anomalies = [
        (lng, lat, reverse_map[ind], conf)
        for (lng, lat), (ind, conf) in zip(locations, out)
        if ind != 2  #! Make sure the check matches with the 'Flat' used earlier
    ]

    sp.add_anomaly_array(detected_anomalies)


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
@throttle_classes([UserRateThrottle, AnonRateThrottle])
def anomaly_sensor_data_collection_view(request):
    try:
        # Extract anomaly data from request body
        anomaly_data = request.data.get("anomaly_data")
        source = request.data.get("source")

        # !----------------------------------------------------------------------------
        # save the request data to a local file:
        name = str(uuid.uuid4())

        if not os.path.exists("savedAnomalies/"):
            os.makedirs("savedAnomalies/")

        with open(f"savedAnomalies/{source}-{name}.json", "w") as file:
            json.dump(anomaly_data, file, indent=4)

        # ! ===========================================================================

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
        locationList = []
        anomalyList = []

        # Process each anomaly
        for anomaly in anomaly_data:
            if not isinstance(anomaly, dict):
                return Response(
                    {"error": "Each anomaly entry must be a dictionary."},
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
            locationList.append((longitude, latitude))
            anomalyList.append(window)

        # todo  <---------------------------------------------------------------------------------- modify this
        # if source == "jimmy":
        #     print("recieved data from jimmy")
        # handle data from jimmy
        # else:
        #     print("recieved data from mobile")
        # handle data from mobile

        # send anomalyList to the model here..
        # the shape of anomaly list will be (no of anomalies, 200, 3)
        # the reason I'm sending them as batches and not one at a time is to possibly speed up inference
        sensor_data_task.delay(locationList, anomalyList)

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


@shared_task
def image_data_task(locations: list[tuple[float, float]], images: list[bytearray]):
    out = vision_predict_anomaly_class(images)

    reverse_map = {3: "Cracks", 1: "Pothole"}

    detected_anomalies = []
    for (lng, lat), arr_for_image in zip(locations, out):

        anomalies_for_image = [
            (lng, lat, reverse_map.get(ind), conf)
            for (ind, conf) in arr_for_image
            if ind in reverse_map  #! This should be unreachable actually
        ]
        detected_anomalies.extend(anomalies_for_image)
    sp.add_anomaly_array(detected_anomalies)


@api_view(["POST"])
@throttle_classes([UserRateThrottle, AnonRateThrottle])
def anomaly_image_data_collection_view(request):
    try:
        images = request.FILES.getlist("image")
        if not images:
            return Response(
                {"error": "No images found in request."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        source = request.data.get("source")
        lat = request.data.getlist("lat")
        lng = request.data.getlist("lng")

        if not source or not isinstance(source, str):
            return Response(
                {"error": "Invalid source."}, status=status.HTTP_400_BAD_REQUEST
            )

        if len(lat) != len(images) or len(lng) != len(images):
            return Response(
                {"error": "Latitudes and longitudes must match number of images."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Vision model processing here
        image_list = []

        for image in images:
            image = image.read()
            kind = filetype.guess(image)

            if kind is None or kind.extension not in ["jpg", "jpeg", "png"]:
                return Response(
                    {"error": "Invalid image type or contents."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            image_list.append(image)
        image_data_task.delay(list(zip(lng, lat)), image_list)

        # print(vision_model_outputs.id)

        return Response(
            {
                "message": "Anomaly image data received successfully!",
            },
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
