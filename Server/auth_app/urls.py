from django.urls import path
from .views import CustomTokenObtainPairView, CustomTokenRefreshView, fixed_anomaly_view
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path("token/", CustomTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", CustomTokenRefreshView.as_view(), name="token_refresh"),
    path("anomaly/fixed/", fixed_anomaly_view, name="fixed_anomaly"),
]
