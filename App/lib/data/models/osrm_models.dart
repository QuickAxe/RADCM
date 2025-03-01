import 'package:latlong2/latlong.dart';

class RouteResponse {
  final String code;
  final List<MatchingModel> matchings;
  // NOTE: The response also contained tracepoints, which i've omitted for now

  RouteResponse({
    required this.code,
    required this.matchings,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      code: json['code'],
      matchings: (json['matchings'] as List)
          .map((route) => MatchingModel.fromJson(route))
          .toList(),
    );
  }
}

class MatchingModel {
  final double confidence;
  final Geometry geometry;
  final List<Leg> legs;
  final String weightName;
  final double weight;
  final double duration;
  final double distance;

  MatchingModel({
    required this.confidence,
    required this.geometry,
    required this.legs,
    required this.weightName,
    required this.weight,
    required this.distance,
    required this.duration,
  });

  factory MatchingModel.fromJson(Map<String, dynamic> json) {
    return MatchingModel(
      confidence: (json['confidence'] as num).toDouble(),
      geometry: Geometry.fromJson(json['geometry']),
      legs: (json['legs'] as List).map((leg) => Leg.fromJson(leg)).toList(),
      weightName: json['weight_name'],
      weight: (json['weight'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
    );
  }
}

class Geometry {
  final List<LatLng> coordinates;
  final String type;

  Geometry({
    required this.coordinates,
    required this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> data) {
    return Geometry(
      coordinates: (data['coordinates'] as List)
          .map((coord) => LatLng(
              coord[1],
              coord[
                  0])) // makes sure its a lat lng, since matching returns lng, lat
          .toList(),
      type: data['type'],
    );
  }
}

class Leg {
  final List<Step> steps;
  final String summary;
  final double weight;
  final double duration;
  final double distance;

  Leg({
    required this.steps,
    required this.summary,
    required this.weight,
    required this.distance,
    required this.duration,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      steps:
          (json['steps'] as List).map((step) => Step.fromJson(step)).toList(),
      summary: json['summary'],
      weight: (json['weight'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
    );
  }
}

class Step {
  final Geometry geometry;
  final Maneuver maneuver;
  final String name;
  final double distance;
  final double duration;
  // NOTE: the response also contained {intersections},weight, mode, driving_side that was not added

  Step({
    required this.geometry,
    required this.maneuver,
    required this.distance,
    required this.duration,
    required this.name,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      geometry: Geometry.fromJson(json['geometry']),
      maneuver: Maneuver.fromJson(json['maneuver']),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      name: json['name'] ?? "",
    );
  }
}

class Maneuver {
  final LatLng location;
  final String type;
  final int bearingBefore;
  final int bearingAfter;
  final String? modifier; // e.g., "right", "left"

  Maneuver({
    required this.location,
    required this.type,
    required this.bearingBefore,
    required this.bearingAfter,
    this.modifier,
  });

  factory Maneuver.fromJson(Map<String, dynamic> json) {
    return Maneuver(
      location: LatLng(json['location'][1], json['location'][0]),
      type: json['type'],
      bearingBefore: json['bearing_before'],
      bearingAfter: json['bearing_after'],
      modifier: json['modifier'],
    );
  }
}
