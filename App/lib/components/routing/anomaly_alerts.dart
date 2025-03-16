import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../data/models/route_models.dart';
import '../../services/overlayNotificationService.dart';

class AnomalyAlerts extends StatefulWidget {
  final List<RouteSegment> segments;
  const AnomalyAlerts({
    super.key,
    required this.segments,
  });

  @override
  State<AnomalyAlerts> createState() => _AnomalyAlertsState();
}

class _AnomalyAlertsState extends State<AnomalyAlerts> {
  StreamSubscription<Position>? positionStream;
  final Set<Anomaly> notifiedAnomalies = {};
  Anomaly? currentAnomaly;
  OverlaySupportEntry? overlayWidget;

  @override
  void initState() {
    super.initState();
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      Anomaly? upcomingAnomaly = getNextAnomaly(position, widget.segments);

      if (upcomingAnomaly != null &&
          !notifiedAnomalies.contains(upcomingAnomaly)) {
        OverlayNotificationService()
            .showNotification("${upcomingAnomaly.category} ahead!");
        setState(() {
          currentAnomaly = upcomingAnomaly;
          notifiedAnomalies.add(upcomingAnomaly);
        });
      } else if (upcomingAnomaly != null &&
          hasUserPassedAnomaly(position, currentAnomaly!)) {
        log("User passed anomaly: ${currentAnomaly!.category}");
        setState(() {
          notifiedAnomalies.remove(currentAnomaly);
          currentAnomaly = null;
        });
      }
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Anomaly? getNextAnomaly(Position userPosition, List<RouteSegment> segments) {
    const double notificationThreshold = 500; // within how many metres
    final Distance distance = Distance();
    LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);

    Anomaly? nextAnomaly;
    double minDistance = double.infinity;

    for (var segment in segments) {
      for (var anomaly in segment.anomalies) {
        LatLng anomalyLatLng = LatLng(anomaly.latitude, anomaly.longitude);
        double dist = distance.as(
          LengthUnit.Meter,
          userLatLng,
          anomalyLatLng,
        );

        if (dist < minDistance &&
            dist > 5 &&
            isAhead(userLatLng, anomalyLatLng, segment)) {
          minDistance = dist;
          nextAnomaly = anomaly;
        }
      }
    }
    return (minDistance <= notificationThreshold) ? nextAnomaly : null;
  }

  bool isAhead(LatLng user, LatLng anomaly, RouteSegment segment) {
    if (segment.geometry.coordinates.length < 2) return true;

    LatLng start = segment.geometry.coordinates.first;
    LatLng end = segment.geometry.coordinates.last;
    double userToStart = Geolocator.distanceBetween(
        user.latitude, user.longitude, start.latitude, start.longitude);
    double userToEnd = Geolocator.distanceBetween(
        user.latitude, user.longitude, end.latitude, end.longitude);
    double anomalyToEnd = Geolocator.distanceBetween(
        anomaly.latitude, anomaly.longitude, end.latitude, end.longitude);
    return anomalyToEnd <
        userToEnd; // if anomaly is closer to dest than user than it ahead
  }

  bool hasUserPassedAnomaly(Position user, Anomaly anomaly) {
    const double threshold =
        1; // how much user needs to go ahead of anomaly in m to be called 'passed anomaly'
    double dist = Geolocator.distanceBetween(
        user.latitude, user.longitude, anomaly.latitude, anomaly.longitude);
    return dist > threshold;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
