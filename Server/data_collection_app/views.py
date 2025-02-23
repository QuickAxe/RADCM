from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response

@api_view(["POST"])
def anomaly_data_collection_view(request):
    return Response(
        {
            "message": "Coordinates received successfully!",
            "routes": "routes",
        },
        status=status.HTTP_200_OK,
    )
