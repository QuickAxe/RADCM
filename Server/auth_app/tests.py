from django.contrib.auth.models import User
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.urls import reverse
from dotenv import load_dotenv
import os


class AuthAndAnomalyTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username=os.environ.get("USERNAME"), password=os.environ.get("PASSWORD")
        )
        self.client = APIClient()
        self.token_url = "/api/token/"
        self.refresh_url = "/api/token/refresh/"
        self.fixed_anomaly_url = "/api/anomaly/fixed/"

    def test_token_obtain_pair_valid_credentials(self):
        response = self.client.post(
            self.token_url,
            {
                "username": os.environ.get("USERNAME"),
                "password": os.environ.get("PASSWORD"),
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)

    def test_token_obtain_pair_invalid_credentials(self):
        response = self.client.post(
            self.token_url,
            {"username": "testuser", "password": "wrongpass"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_token_refresh_valid(self):
        refresh = RefreshToken.for_user(self.user)
        response = self.client.post(
            self.refresh_url, {"refresh": str(refresh)}, format="json"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)

    def test_token_refresh_invalid(self):
        response = self.client.post(
            self.refresh_url, {"refresh": "invalid.token.here"}, format="json"
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_fixed_anomaly_valid_authenticated(self):
        token = RefreshToken.for_user(self.user).access_token
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        response = self.client.delete(
            self.fixed_anomaly_url,
            {"latitude": 12.9716, "longitude": 77.5946},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["message"], "Coordinates received successfully!")

    def test_fixed_anomaly_missing_fields(self):
        token = RefreshToken.for_user(self.user).access_token
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        response = self.client.delete(
            self.fixed_anomaly_url, {"latitude": 12.9716}, format="json"
        )
        self.assertEqual
