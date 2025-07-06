# Rosto Radar - RADCM 
**Road Anomaly Detection, Classification & Mapping**

Rosto Radar is a real-time road anomaly detection and mapping system built as part of our final year Computer Engineering project. 

> The goal is simple - To provide a cheap yet efficient solution for road anomaly detection and mapping in real-time.

## Overview

Rosto Radar is an automated system that uses data from user smartphones, modules mounted on heavy/commercial vehicles, and drones. It uses user's phones to map road anomalies like potholes, speed breakers, and rumble strips etc and delivers real-time alerts to users about newly identified anomalies and provides authorities with a dedicated interface for locating, navigating to, and resolving these issues efficiently.

## Key Features

- Real-time anomaly detection using:
  - Smartphone sensors (Accelerometer, GPS)
  - Custom MPU-6050 hardware modules on heavy/commercial vehicles
  - UAV-based aerial image surveys
  
- Dual ML Model System:
  - Sensor data → **CNN-based classifier**
  - Image data → **YOLOv11 vision model**
  
- Dynamic routing:
  - Choose routes based on **shortest path (dijkstra)** or **least anomalies (dijkstra with added weight for anomalies)**

- Flutter mobile apps:
  - User App: Live anomaly alerts, route planning
  - Authority App: View & mark anomalies as fixed

- Django-based backend:
  - RESTful API
  - JWT authentication
  - PostgreSQL + PostGIS + Redis + Celery
  - Tile server for map rendering

## Tech Stack
Frontend - Flutter (User & Admin Apps)
Backend - Django + Django REST Framework
Database - PostgreSQL + PostGIS
ML Models - YOLOv11 (Vision), CNN (Sensor), PyTorch
Hardware - ESP8266, MPU6050, Raspberry Pi Zero W, GPS
Deployment - NGINX, Gunicorn, Docker, Redis, Celery

## 📱 App Screens and other pics\
> add pics, pics, pics

