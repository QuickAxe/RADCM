import 'dart:async';

import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/models/route_models.dart';
import '../../services/providers/user_settings.dart';
import '../../services/tbt_location_service.dart';
import '../../services/tts_service.dart';

/// A widget that displays the next valid turn-by-turn direction dynamically.
class DynamicRouteDirections extends StatefulWidget {
  final RouteModel route;

  const DynamicRouteDirections({super.key, required this.route});

  @override
  _DynamicRouteDirectionsState createState() => _DynamicRouteDirectionsState();
}

class _DynamicRouteDirectionsState extends State<DynamicRouteDirections> {
  final TbtLocationService _locationService = TbtLocationService();
  late TtsService _ttsService;
  String?
      _lastSpokenInstruction; // This is required to prevent TTS from repeating instructions

  StreamSubscription<Position>? posStream;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final userSettings =
        Provider.of<UserSettingsProvider>(context, listen: false);
    _ttsService = TtsService(userSettings);
    _updateCurrentIndex();
  }

  @override
  void dispose() {
    _locationService.cancelStream();
    posStream?.cancel();
    super.dispose();
  }

  void _updateCurrentIndex() {
    posStream =
        _locationService.getPositionStream().listen((Position position) {
      double userLat = position.latitude;
      double userLng = position.longitude;

      int bestIndex = _currentIndex;

      if (kDebugMode) {
        print("User Location: $userLng, $userLat");
      }

      if (_currentIndex < widget.route.segments.length - 1) {
        final step1 = widget.route.segments[_currentIndex].geometry;
        final step2 = widget.route.segments[_currentIndex + 1].geometry;

        double step1Lat = step1.coordinates[0].latitude;
        double step1Lng = step1.coordinates[0].longitude;
        double step2Lat = step2.coordinates[0].latitude;
        double step2Lng = step2.coordinates[0].longitude;

        if (_hasPassedCheckpoint(
            step1Lat, step1Lng, step2Lat, step2Lng, userLat, userLng)) {
          bestIndex = _currentIndex + 1;
        }
      } else {
        // dont need stream after user reaches the last
        posStream!.cancel();
        return;
      }

      if (bestIndex != _currentIndex && mounted) {
        setState(() {
          _currentIndex = bestIndex;
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

  /// Returns an appropriate icon for the given maneuver type
  IconData _getManeuverIcon(String? turnDirection) {
    switch (turnDirection) {
      case "START":
        return LucideIcons.navigation;
      case "STRAIGHT":
        return LucideIcons.arrowUp;
      case "LEFT":
        return LucideIcons.arrowLeft;
      case "SLIGHTLY LEFT":
        return LucideIcons.cornerUpLeft;
      case "RIGHT":
        return LucideIcons.arrowRight;
      case "SLIGHTLY RIGHT":
        return LucideIcons.cornerUpRight;
      default:
        return LucideIcons.arrowUp;
    }
  }

  /// Returns an appropriate icon for the given maneuver type
  String _getManeuverInstruction(
      String? turnDirection, String formattedDistance) {
    switch (turnDirection) {
      case "START":
        return "Start your journey & continue ahead";
      case "STRAIGHT":
        return "Continue Straight for $formattedDistance";
      case "LEFT":
        return "Take the next left";
      case "SLIGHTLY LEFT":
        return "At the incoming fork, take a slight left";
      case "RIGHT":
        return "Take the next right";
      case "SLIGHTLY RIGHT":
        return "At the incoming fork, take a slight right";
      default:
        return "Start your journey & continue ahead";
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.route.segments[_currentIndex].maneuver.turnDirection;

    String roadName = "Unnamed road";
    String? turnDirection =
        widget.route.segments[_currentIndex].maneuver.turnDirection;

    String instruction = _getManeuverInstruction(turnDirection,
        "${widget.route.segments[_currentIndex].cost.toInt()} meters");

    if (_lastSpokenInstruction != instruction) {
      _ttsService.speak(instruction);
      _lastSpokenInstruction = instruction;
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        ListTile(
          titleAlignment: ListTileTitleAlignment.center,
          leading: Icon(
            _getManeuverIcon(
                widget.route.segments[_currentIndex].maneuver.turnDirection),
            color: context.theme.colorScheme.primary,
          ),
          title: Text(
            instruction,
            style: context.theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
