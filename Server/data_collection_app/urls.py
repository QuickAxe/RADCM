from django.urls import path
from .views import anomaly_sensor_data_collection_view, anomaly_image_data_collection_view

urlpatterns = [
    path('anomalies/sensors/', anomaly_sensor_data_collection_view, name='anomaly_sensor_data_collection'),
    path('anomalies/images/', anomaly_image_data_collection_view, name='anomaly_image_data_collection'),
]
