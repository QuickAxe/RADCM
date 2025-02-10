from django.urls import path, re_path
from .views import my_view

urlpatterns = [
    re_path(r'^(?P<coords>[-\d.,;]+)$', my_view, name ="path")
]