from django.urls import path
from .views import anomalies_in_region_view, routes_view

urlpatterns = [
    path('anomalies/', anomalies_in_region_view, name='anomalies_in_region_view'),
    path('routes/', routes_view, name='routes_view'),
]
