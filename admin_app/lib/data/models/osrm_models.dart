class RouteResponse {
  final String code;
  final List<RouteModel> routes;
  final List<Waypoint> waypoints;

  RouteResponse({
    required this.code,
    required this.routes,
    required this.waypoints,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      code: json['code'],
      routes: (json['routes'] as List)
          .map((route) => RouteModel.fromJson(route))
          .toList(),
      waypoints: (json['waypoints'] as List)
          .map((wp) => Waypoint.fromJson(wp))
          .toList(),
    );
  }
}

class RouteModel {
  final List<Leg> legs;
  final double distance;
  final double duration;
  final String summary;

  RouteModel({
    required this.legs,
    required this.distance,
    required this.duration,
    required this.summary,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      legs: (json['legs'] as List).map((leg) => Leg.fromJson(leg)).toList(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      summary: json['summary'] ?? "",
    );
  }
}

class Leg {
  final List<Step> steps;

  // You can add additional fields such as distance, duration, etc.
  final double distance;
  final double duration;

  Leg({
    required this.steps,
    required this.distance,
    required this.duration,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      steps:
          (json['steps'] as List).map((step) => Step.fromJson(step)).toList(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
    );
  }
}

class Step {
  final String geometry;
  final Maneuver maneuver;
  final double distance;
  final double duration;
  final String name;

  Step({
    required this.geometry,
    required this.maneuver,
    required this.distance,
    required this.duration,
    required this.name,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      geometry: json['geometry'],
      maneuver: Maneuver.fromJson(json['maneuver']),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      name: json['name'] ?? "",
    );
  }
}

class Maneuver {
  final List<double> location;
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
      location: (json['location'] as List)
          .map((loc) => (loc as num).toDouble())
          .toList(),
      type: json['type'],
      bearingBefore: json['bearing_before'],
      bearingAfter: json['bearing_after'],
      modifier: json['modifier'],
    );
  }
}

class Waypoint {
  final String name;
  final double distance;
  final List<double> location;

  Waypoint({
    required this.name,
    required this.distance,
    required this.location,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      name: json['name'],
      distance: (json['distance'] as num).toDouble(),
      location: (json['location'] as List)
          .map((loc) => (loc as num).toDouble())
          .toList(),
    );
  }
}
