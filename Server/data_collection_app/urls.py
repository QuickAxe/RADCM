from django.urls import path
from .views import anomaly_data_collection_view

urlpatterns = [
    path('anomalies/reports/', anomaly_data_collection_view, name='anomaly_data_collection'),
]
