import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/osrm_models.dart';
import '../../utils/route_utils.dart';
import '../../utils/string_utils.dart';

/// A widget that displays the next valid turn-by-turn direction dynamically.
class DynamicRouteDirections extends StatefulWidget {
  final RouteModel route;

  const DynamicRouteDirections({super.key, required this.route});

  @override
  _DynamicRouteDirectionsState createState() => _DynamicRouteDirectionsState();
}

class _DynamicRouteDirectionsState extends State<DynamicRouteDirections> {
  StreamSubscription<Position>? posStream;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentStep();
  }

  @override
  void dispose() {
    posStream?.cancel();
    super.dispose();
  }

  void _updateCurrentStep() {
    posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    ).listen((Position position) {
      double userLat = position.latitude;
      double userLng = position.longitude;

      int bestIndex = _currentStepIndex;

      print("User Location: $userLng, $userLat");

      if (_currentStepIndex < widget.route.legs.first.steps.length - 1) {
        final step1 = widget.route.legs.first.steps[_currentStepIndex];
        final step2 = widget.route.legs.first.steps[_currentStepIndex + 1];

        double step1Lat = step1.maneuver.location[1];
        double step1Lng = step1.maneuver.location[0];
        double step2Lat = step2.maneuver.location[1];
        double step2Lng = step2.maneuver.location[0];

        if (_hasPassedCheckpoint(
            step1Lat, step1Lng, step2Lat, step2Lng, userLat, userLng)) {
          bestIndex = _currentStepIndex + 1;
        }
      } else {
        // dont need stream after user reaches da last
        posStream!.cancel();
      }

      if (bestIndex != _currentStepIndex) {
        setState(() {
          _currentStepIndex = bestIndex;
        });
      }
    });
  }

  bool _hasPassedCheckpoint(double step1Lat, double step1Lng, double step2Lat,
      double step2Lng, double userLat, double userLng) {
    double vecX = step2Lng - step1Lng;
    double vecY = step2Lat - step1Lat;

    double userVecX = userLng - step1Lng;
    double userVecY = userLat - step1Lat;

    // dot product
    double dotProduct = (vecX * userVecX) + (vecY * userVecY);

    return dotProduct > 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (widget.route.legs.isEmpty) {
      return const Center(child: Text("No directions available"));
    }

    // final step = widget.route.legs.first.steps[_currentStepIndex];

    String roadName =
        widget.route.legs.first.steps[_currentStepIndex].name.isNotEmpty
            ? capitalize(widget.route.legs.first.steps[_currentStepIndex].name)
            : "Unnamed road";
    String maneuverType =
        widget.route.legs.first.steps[_currentStepIndex].maneuver.type;
    String? maneuverModifier =
        widget.route.legs.first.steps[_currentStepIndex].maneuver.modifier;

    String instruction =
        generateVerboseInstruction(maneuverType, maneuverModifier, roadName);

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        ListTile(
          leading: Icon(
            getManeuverIcon(
                widget.route.legs.first.steps[_currentStepIndex].maneuver.type,
                widget.route.legs.first.steps[_currentStepIndex].maneuver
                    .modifier),
            color: theme.colorScheme.primary,
          ),
          title: Text(
            instruction,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Distance: ${formatDistance(widget.route.legs.first.steps[_currentStepIndex].distance)} | Duration: ${formatDuration(widget.route.legs.first.steps[_currentStepIndex].duration)}",
            style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
