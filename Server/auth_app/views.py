from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.models import User
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from rest_framework.response import Response
from rest_framework.throttling import UserRateThrottle, ScopedRateThrottle


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        return data


class CustomTokenObtainPairView(TokenObtainPairView):
    throttle_scope = "token_obtain"
    throttle_classes = [ScopedRateThrottle]
    serializer_class = CustomTokenObtainPairSerializer


class CustomTokenRefreshView(TokenRefreshView):
    throttle_scope = "token_refresh"
    throttle_classes = [ScopedRateThrottle]


@api_view(["DELETE"])
@permission_classes([IsAuthenticated])
@throttle_classes([UserRateThrottle])
def fixed_anomaly_view(request):
    try:
        # Extract latitude and longitude from request body (expects JSON)
        latitude = request.data.get("latitude")
        longitude = request.data.get("longitude")

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

        # Success response
        # print("go sing a song.. it works")

        return Response(
            {"message": "Coordinates received successfully!"},
            status=status.HTTP_200_OK,
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
