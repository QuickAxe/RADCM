import 'dart:async';

import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/models/route_models.dart';
import '../../services/providers/user_settings.dart';
import 'anomaly_notification.dart';

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
  final Distance distance = Distance();
  List<AnomalyWithDistance> activeAnomalies = [];

  @override
  void initState() {
    super.initState();
    // ??= check fi positionStream is null and only assigns if it is, doing this to ensure that we dont spawn multiple listeners to the pos stream
    positionStream ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      List<Anomaly> upcoming = getUpcomingAnomalies(position, widget.segments);

      setState(() {
        activeAnomalies.removeWhere((anomalyWithDistance) =>
            hasUserPassedAnomaly(position, anomalyWithDistance.anomaly));
        for (var anomaly in upcoming) {
          if (!activeAnomalies.any((item) => item.anomaly == anomaly)) {
            // Calculate the distance and store it with the anomaly
            double distanceToAnomaly = calculateDistance(position, anomaly);
            activeAnomalies.add(AnomalyWithDistance(
                anomaly: anomaly, distance: distanceToAnomaly));
          }
        }
        // this shud only keep the top 3 closest anomalies, why closest since we traversing the segments and detecting anomalies, the new ones are added at the bottom, the new ones are the further ones, so we only keep 3 from top since they oldest, closest
        if (activeAnomalies.length > 3) {
          activeAnomalies = activeAnomalies.sublist(0, 3);
        }
      });
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    positionStream = null;
    super.dispose();
  }

  List<Anomaly> getUpcomingAnomalies(
      Position userPosition, List<RouteSegment> segments) {
    const double notificationThreshold = 500; // within how many meters
    LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
    List<Anomaly> anomalies = [];

    for (var segment in segments) {
      for (var anomaly in segment.anomalies) {
        LatLng anomalyLatLng = LatLng(anomaly.latitude, anomaly.longitude);
        double dist = distance.as(LengthUnit.Meter, userLatLng, anomalyLatLng);

        if (dist <= notificationThreshold &&
            dist > 5 &&
            isAhead(userLatLng, anomalyLatLng, segment)) {
          anomalies.add(anomaly);
        }
      }
    }

    anomalies.sort((a, b) {
      double distA = distance.as(
          LengthUnit.Meter, userLatLng, LatLng(a.latitude, a.longitude));
      double distB = distance.as(
          LengthUnit.Meter, userLatLng, LatLng(b.latitude, b.longitude));
      return distA.compareTo(distB);
    });

    return anomalies;
  }

  double calculateDistance(Position userPosition, Anomaly anomaly) {
    final Distance distance = Distance();
    LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
    LatLng anomalyLatLng = LatLng(anomaly.latitude, anomaly.longitude);
    return distance.as(LengthUnit.Meter, userLatLng, anomalyLatLng);
  }

  bool isAhead(LatLng user, LatLng anomaly, RouteSegment segment) {
    if (segment.geometry.coordinates.length < 2) return true;

    LatLng start = segment.geometry.coordinates.first;
    LatLng end = segment.geometry.coordinates.last;
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
    final userSettings = context.watch<UserSettingsProvider>();
    final enabledAlerts = userSettings.alertWhileRiding;

    final filteredAnomalies = activeAnomalies.where((anomalyWithDistance) {
      final category = anomalyWithDistance.anomaly.category;
      return enabledAlerts[category] ?? false;
    }).toList();

    // if (filteredAnomalies.isEmpty) {
    //   return const SizedBox.shrink();
    // }

    return Positioned(
      top: 35,
      left: 12,
      right: 12,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceDim.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: Column(
            key: ValueKey(filteredAnomalies.length),
            children: filteredAnomalies.isEmpty
                ? [
                    Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryFixed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(LucideIcons.checkCircle2,
                            color: Colors.green),
                        title: Text("All Clear! No Anomalies ahead",
                            style: TextStyle(
                                color: context.colorScheme.onPrimaryFixed,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ),
                    ),
                  ]
                : filteredAnomalies
                    .map((anomalyWithDistance) => AnomalyNotificationWidget(
                          category: anomalyWithDistance.anomaly.category,
                          message:
                              "${anomalyWithDistance.anomaly.category} ahead!",
                          distance: anomalyWithDistance.distance,
                        ))
                    .toList(),
          ),
        ),
      ),
    );
  }
}

class AnomalyWithDistance {
  final Anomaly anomaly;
  final double distance;

  AnomalyWithDistance({
    required this.anomaly,
    required this.distance,
  });
}
