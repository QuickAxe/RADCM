# Rosto Radar - RADCM
#### Road Anomaly Detection, Classification & Mapping
[![Use App](https://img.shields.io/badge/release-v1.16.2%2Buser-blue?style=for-the-badge)](https://github.com/quickaxe/radcm/releases/tag/v1.16.2%2Buser)
[![Admin App](https://img.shields.io/badge/release-v0.16.1%2Badmin-orange?style=for-the-badge)](https://github.com/quickaxe/radcm/releases/tag/v0.16.1%2Badmin)

<!-- <img align="right" src="https://github.com/user-attachments/assets/4da71a81-55bd-4fef-9ba0-d528095c6d83" width="300"> -->

Rosto Radar is a real-time road anomaly detection and mapping system built as part of our final year Computer Engineering project. 

> The goal is simple - To provide a cheap yet efficient solution for road anomaly detection, mapping and closure in real-time.
While some systems do use sensors, most still rely on expensive survey vehicles or manual reporting. We aimed to build a scalable, crowd-powered approach that works in real time.

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

## The User App
#### Anomalies are displayed as clusters and reveal as you zoom into them, and their visibility can be toggled
<picture style="display: block;">
  <source
    media="(prefers-color-scheme: dark)"
    srcset="https://github.com/user-attachments/assets/a2db0da9-c2bc-450a-b405-18f1dfc9951f"/>
  <img
    src="https://github.com/user-attachments/assets/d80a4669-da24-4592-b86b-3a346f5e82d8"
    style="width: 100%; display: block;"
    alt="UI-1"/>
</picture>

#### Anomaly aware routes provide users a shortest route and a route that avoids anomalies but may be slightly longer
<picture style="display: block;">
  <source
    media="(prefers-color-scheme: dark)"
    srcset="https://github.com/user-attachments/assets/2bef8cd9-e3b3-48be-8eac-f77f7270d5e2"/>
  <img
    src="https://github.com/user-attachments/assets/07b79bcf-df0e-4986-842e-0e559b606944"
    style="width: 100%; display: block;"
    alt="UI-1"/>
</picture>

## The Admin App
We also made an app to allow authorities to quickly find and fix anomalies, start a survey using the UAV, navigate to anomalies and more

<picture style="display: block;">
  <source
    media="(prefers-color-scheme: dark)"
    srcset="https://github.com/user-attachments/assets/21670274-5aac-4f88-afb5-9e421f8ee0e7"/>
  <img
    src="https://github.com/user-attachments/assets/0f9f5dc0-3cbd-4ab9-ae90-48a8ec2996b6"
    style="width: 100%; display: block;"
    alt="UI-1"/>
</picture>


## The UAV
Not all areas are easily accessible by ground vehicles. Some roads may be flooded, blocked, or unsafe for driving. In such cases, we used UAVs to survey and map these regions from above. Here's a picture of the drone we worked on.

<img src="https://github.com/user-attachments/assets/603d10d0-b0b3-4eab-9e29-316fd3526180" width="400">

## MPU6050 Module
This module performs the same core function as the smartphone sensors i.e. detecting road anomalies. However, it is a specialized, low-cost hardware unit specifically designed for this purpose. Its compact and durable design allows it to be easily mounted on public transport vehicles such as buses, trucks, or service fleets.

<img src="https://github.com/user-attachments/assets/579a1d2a-774b-4fb9-b04c-7b6f68afbda7" width="400">
