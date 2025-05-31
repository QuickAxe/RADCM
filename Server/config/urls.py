"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

# from path.views import my_view

urlpatterns = [
    # path("", lambda request: HttpResponse("RADCM Backend")),
    path(
        "admin/", admin.site.urls
    ),  # admin can add users who can then log in to the authority app
    path("api/", include("auth_app.urls")),
    path("api/", include("navigation_app.urls")),
    path("api/", include("data_collection_app.urls")),
    # path("path/", include("path.urls")),
]

# --------------------------------------- Active API end-points ---------------------------------------
# api/token/ - for user Login [POST]
# api/token/refresh/ - to refresh user Login [POST]
# api/anomaly/fixed/ - to fix an anomaly [DELETE]
# api/anomalies/ - to retrieve a list of anomalies around a (latitude, longitude) [GET]
# api/anomalies/sensors/ - to report anomlies (sensor data collector) [POST]
# api/anomalies/images/ - to report anomlies (image data collector) [POST]
# api/routes/ - to get routes from (latitudeStart, longitudeStart) to (latitudeEnd, longitudeEnd) [GET]

# ws://host:port/ws/anomaly_updates/ - to receive anomaly updates in real-time (WebSocket connection) [GET]
