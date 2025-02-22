from django.urls import path
from .views import CustomTokenObtainPairView, fixed_anomaly_view
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('anomaly/', fixed_anomaly_view, name='fixed_anomaly_view'),
]
