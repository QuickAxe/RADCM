from django.test import TestCase
from rest_framework.test import APIClient
from unittest.mock import patch
from django.urls import reverse
import io
from PIL import Image
import json

# kjbjb


class AnomalyViewsTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.sensors_url = "/api/anomalies/sensors/"
        self.images_url = "/api/anomalies/images/"

    @patch("data_collection_app.views.sensor_data_task.delay")
    def test_anomaly_sensor_data_collection_valid(self, mock_task):
        url = self.sensors_url
        data = {
            "source": "mobile",
            "anomaly_data": [
                {
                    "latitude": 12.9716,
                    "longitude": 77.5946,
                    "window": [[1.0, 2.0, 3.0]] * 200,
                }
            ],
        }
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertIn("message", response.data)
        mock_task.assert_called_once()

    def test_anomaly_sensor_data_collection_missing_data(self):
        url = self.sensors_url
        response = self.client.post(url, {"source": "mobile"}, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.data)

    def test_anomaly_sensor_data_collection_invalid_latlon(self):
        url = self.sensors_url
        data = {
            "source": "mobile",
            "anomaly_data": [
                {
                    "latitude": "invalid",
                    "longitude": 77.5946,
                    "window": [[1.0, 2.0, 3.0]] * 200,
                }
            ],
        }
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.data)

    def test_anomaly_sensor_data_collection_wrong_window_length(self):
        url = self.sensors_url
        data = {
            "source": "mobile",
            "anomaly_data": [
                {
                    "latitude": 12.9716,
                    "longitude": 77.5946,
                    "window": [[1.0, 2.0, 3.0]] * 199,
                }
            ],
        }
        response = self.client.post(url, data, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.data)

    @patch("data_collection_app.views.image_data_task.delay")
    def test_anomaly_image_data_collection_valid(self, mock_task):
        url = self.images_url
        image = Image.new("RGB", (60, 30), color=(73, 109, 137))
        byte_arr = io.BytesIO()
        image.save(byte_arr, format="PNG")
        byte_arr.seek(0)

        data = {
            "source": "mobile",
            "lat": ["12.9716"],
            "lng": ["77.5946"],
            "image": [byte_arr],
        }
        response = self.client.post(url, data, format="multipart")
        self.assertEqual(response.status_code, 200)
        self.assertIn("message", response.data)
        mock_task.assert_called_once()

    def test_anomaly_image_data_collection_no_images(self):
        url = self.images_url
        data = {
            "source": "mobile",
            "lat": ["12.9716"],
            "lng": ["77.5946"],
        }
        response = self.client.post(url, data, format="multipart")
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.data)

    def test_anomaly_image_data_collection_mismatched_coords(self):
        url = self.images_url
        image = Image.new("RGB", (60, 30), color=(73, 109, 137))
        byte_arr = io.BytesIO()
        image.save(byte_arr, format="PNG")
        byte_arr.seek(0)

        data = {
            "source": "mobile",
            "lat": ["12.9716", "12.9717"],
            "lng": ["77.5946"],
            "image": [byte_arr],
        }
        response = self.client.post(url, data, format="multipart")
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.data)

    def test_anomaly_image_data_collection_invalid_image(self):
        url = self.images_url
        byte_arr = io.BytesIO(b"notanimage")
        byte_arr.name = "test.txt"

        data = {
            "source": "mobile",
            "lat": ["12.9716"],
            "lng": ["77.5946"],
            "image": [byte_arr],
        }
        response = self.client.post(url, data, format="multipart")
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.data)
