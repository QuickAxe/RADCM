from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from unittest.mock import patch


class AnomalyAndRoutesViewTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.anomalies_url = "/api/anomalies/"
        self.routes_url = "/api/routes/"

    @patch("navigation_app.views.sp.get_anomalies_by_longlat")
    def test_anomalies_valid_request(self, mock_get_anomalies):
        mock_get_anomalies.return_value = [
            {"type": "Pothole", "lat": 12.97, "lng": 77.59}
        ]
        response = self.client.get(
            self.anomalies_url,
            {"latitude": "12.9716", "longitude": "77.5946", "radius": "0.5"},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("anomalies", response.data)

    def test_anomalies_missing_coordinates(self):
        response = self.client.get(self.anomalies_url)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_anomalies_invalid_coordinates(self):
        response = self.client.get(
            self.anomalies_url, {"latitude": "abc", "longitude": "xyz"}
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_anomalies_out_of_range_coordinates(self):
        response = self.client.get(
            self.anomalies_url, {"latitude": "100", "longitude": "200"}
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    @patch("navigation_app.views.sp.get_nodes_from_longlat")
    @patch("navigation_app.views.sp.get_path_by_nodeid")
    def test_routes_valid_request_no_cache(self, mock_get_path, mock_get_nodes):
        mock_get_nodes.return_value = (1, 2)
        mock_get_path.return_value = [{"lat": 12.97, "lng": 77.59}]
        response = self.client.get(
            self.routes_url,
            {
                "latitudeStart": "12.9716",
                "longitudeStart": "77.5946",
                "latitudeEnd": "12.9352",
                "longitudeEnd": "77.6245",
            },
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("routes", response.data)

    def test_routes_missing_coordinates(self):
        response = self.client.get(self.routes_url, {"latitudeStart": "12.9716"})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_routes_invalid_coordinates(self):
        response = self.client.get(
            self.routes_url,
            {
                "latitudeStart": "abc",
                "longitudeStart": "77.5946",
                "latitudeEnd": "12.9352",
                "longitudeEnd": "77.6245",
            },
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_routes_out_of_range_coordinates(self):
        response = self.client.get(
            self.routes_url,
            {
                "latitudeStart": "91",
                "longitudeStart": "181",
                "latitudeEnd": "12.9352",
                "longitudeEnd": "77.6245",
            },
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
