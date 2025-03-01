import 'dart:async';

import 'package:app/util/route_utils.dart';
import 'package:app/util/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../data/models/osrm_models.dart';
import '../../services/providers/user_settings.dart';
import '../../services/tbt_location_service.dart';
import '../../services/tts_service.dart';

/// A widget that displays the next valid turn-by-turn direction dynamically.
class DynamicRouteDirections extends StatefulWidget {
  final MatchingModel route;

  const DynamicRouteDirections({super.key, required this.route});

  @override
  _DynamicRouteDirectionsState createState() => _DynamicRouteDirectionsState();
}

class _DynamicRouteDirectionsState extends State<DynamicRouteDirections> {
  final TbtLocationService _locationService = TbtLocationService();
  late TtsService _ttsService;

  StreamSubscription<Position>? posStream;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    final userSettings =
        Provider.of<UserSettingsProvider>(context, listen: false);
    _ttsService = TtsService(userSettings);
    _updateCurrentStep();
  }

  @override
  void dispose() {
    _locationService.cancelStream();
    super.dispose();
  }

  void _updateCurrentStep() {
    posStream =
        _locationService.getPositionStream().listen((Position position) {
      double userLat = position.latitude;
      double userLng = position.longitude;

      int bestIndex = _currentStepIndex;

      if (kDebugMode) {
        print("User Location: $userLng, $userLat");
      }

      if (_currentStepIndex < widget.route.legs.first.steps.length - 1) {
        final step1 = widget.route.legs.first.steps[_currentStepIndex];
        final step2 = widget.route.legs.first.steps[_currentStepIndex + 1];

        double step1Lat = step1.maneuver.location.latitude;
        double step1Lng = step1.maneuver.location.longitude;
        double step2Lat = step2.maneuver.location.latitude;
        double step2Lng = step2.maneuver.location.longitude;

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
    _ttsService.speak(instruction);
    _ttsService.getVoices();

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
