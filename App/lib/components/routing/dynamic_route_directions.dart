import 'dart:async';

import 'package:app/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/osrm_models.dart';
import '../../util/route_utils.dart';

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

  // text to speech
  late FlutterTts flutterTts;
  int ttsCount = -1;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _updateCurrentStep();
  }

  @override
  void dispose() {
    posStream?.cancel();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    // 1sec delay to avoid collisions during route alignment
    await Future.delayed(const Duration(milliseconds: 1000));

    await flutterTts.setLanguage("en-US"); // Set language
    await flutterTts.setPitch(1.0); // Adjust pitch
    await flutterTts.setSpeechRate(0.4); // Adjust speed
    await flutterTts.speak(text); // Speak the text
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
    if (widget.route.legs.isEmpty) {
      return const Center(child: Text("No directions available"));
    }

    // final step = widget.route.legs.first.steps[_currentStepIndex];

    String roadName =
        widget.route.legs.first.steps[_currentStepIndex].name.isNotEmpty
            ? capitalize(widget.route.legs.first.steps[_currentStepIndex].name)
            : "Unnamed road";
    String instruction =
        "${capitalize(widget.route.legs.first.steps[_currentStepIndex].maneuver.type)} ${widget.route.legs.first.steps[_currentStepIndex].maneuver.modifier ?? ''} on $roadName";

    if(ttsCount != _currentStepIndex) {
      _speak(instruction);
      ttsCount++;
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      children: [
        ListTile(
          leading: Icon(_getManeuverIcon(
              widget.route.legs.first.steps[_currentStepIndex].maneuver.type,
              widget.route.legs.first.steps[_currentStepIndex].maneuver
                  .modifier)),
          title: Text(
            instruction,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Distance: ${formatDistance(widget.route.legs.first.steps[_currentStepIndex].distance)} | Duration: ${formatDuration(widget.route.legs.first.steps[_currentStepIndex].duration)}",
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  /// Returns an appropriate icon for the given maneuver type
  IconData _getManeuverIcon(String maneuverType, String? modifier) {
    switch (maneuverType) {
      case "depart":
        return LucideIcons.navigation;
      case "turn":
        if (modifier == "left") {
          return LucideIcons.cornerUpLeft;
        } else {
          return LucideIcons.cornerUpRight;
        }
      case "continue":
        if (modifier == "left") {
          return LucideIcons.cornerUpLeft;
        } else if (modifier == "right") {
          return LucideIcons.cornerUpRight;
        } else if (modifier == "straight") {
          return LucideIcons.arrowUp;
        } else {
          return LucideIcons.map;
        }
      case "roundabout":
        return LucideIcons.rotateCw;
      case "merge":
        return LucideIcons.merge;
      case "exit":
        return LucideIcons.logOut;
      case "straight":
        return LucideIcons.arrowUp;
      case "arrive":
        return LucideIcons.partyPopper;
      default:
        if (modifier == "left") {
          return LucideIcons.cornerUpLeft;
        } else if (modifier == "right") {
          return LucideIcons.cornerUpRight;
        } else if (modifier == "straight") {
          return LucideIcons.arrowUp;
        } else if (modifier == "slight left") {
          return LucideIcons.arrowUpLeft;
        } else {
          return LucideIcons.map;
        }
    }
  }
}
