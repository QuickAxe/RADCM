import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';

/// The response consists of:
///
/// - `message` (String): A status message from the server.
/// - `routes` (List<List<RouteSegment>>): A list of possible routes.
///   - Each **inner list** represents a **single route** consisting of multiple route segments.
///   - A **RouteSegment** represents a part of the route between two points.
///
/// **RouteSegment Structure:**
/// - `path_seq` (int): The sequential order of the segment within a route.
/// - `polyline` (String): Encoded polyline representing the segment's geometry.
/// - `cost` (double): The cost associated with this segment.
/// - `agg_cost` (double): The accumulated cost up to but not including this segment.
/// - `maneuver` (Maneuver): Metadata about the maneuver at this segment (e.g., turn direction).
///
/// **Maneuver Structure:**
/// - `bearing1` (double): Initial bearing before the maneuver.
/// - `bearing2` (double): Bearing after the maneuver.
///
/// **Geometry Handling:**
/// - `polyline` is **decoded** into a list of `LatLng` points using `flutter_polyline_points`.
class RouteResponse {
  final String message;
  // Each inner list represents a single route
  final List<RouteModel> routes;

  RouteResponse({
    required this.message,
    required this.routes,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    // log("Inside routeresponse factory function");
    return RouteResponse(
      message: json['message'],
      routes: (json['routes'] as List).map((routeData) {
        return RouteModel.fromJson(routeData);
      }).toList(),
    );
  }
}

/// Represents a full route with multiple segments.
/// was named RouteModel because of a conflict with the /src/navigator.dart under material
class RouteModel {
  // the current response does not support these for now, so they are nullable
  final double? distance;
  final double? duration;
  final List<RouteSegment> segments;
  final List<Leg>? legs; // Unsupported, hence nullable

  RouteModel({
    this.distance,
    this.duration,
    required this.segments,
    required this.legs,
  });

  factory RouteModel.fromJson(dynamic json) {
    // log("Inside routemodel factory function");
    List<RouteSegment> segments = [];
    double? computedDistance;

    if (json is List) {
      segments = json.map((segment) => RouteSegment.fromJson(segment)).toList();
    } else if (json is Map<String, dynamic>) {
      // In case the API later returns route-wide details along with segments.
      segments = (json['segments'] as List)
          .map((segment) => RouteSegment.fromJson(segment))
          .toList();
    } else {
      throw Exception("Unexpected route data type: ${json.runtimeType}");
    }

    if (segments.isNotEmpty) {
      computedDistance = segments.last.aggCost;
    }

    return RouteModel(
        distance: computedDistance,
        duration: json is Map<String, dynamic> && json.containsKey("duration")
            ? (json['duration'] as num).toDouble()
            : null,
        segments: segments,
        legs: null);
  }
}

class RouteSegment {
  final int pathSeq;
  final Geometry geometry;
  final double cost;
  final double aggCost;
  final Maneuver maneuver;
  final List<Anomaly> anomalies;

  RouteSegment({
    required this.pathSeq,
    required this.geometry,
    required this.cost,
    required this.aggCost,
    required this.maneuver,
    required this.anomalies,
  });

  factory RouteSegment.fromJson(Map<String, dynamic> json) {
    // log("Inside routesegment factory function");
    return RouteSegment(
        pathSeq: json['path_seq'],
        geometry: Geometry.fromPolyline(json['polyline']),
        cost: (json['cost'] as num).toDouble(),
        aggCost: (json['agg_cost'] as num).toDouble(),
        maneuver: Maneuver.fromJson(json['maneuver']),
        anomalies: json['anomalies'] != null
            ? (json['anomalies'] as List)
                .map((anomaly) => Anomaly.fromJson(anomaly))
                .toList()
            : []);
  }
}

class Geometry {
  final List<LatLng> coordinates;

  Geometry({required this.coordinates});

  factory Geometry.fromPolyline(String polyline) {
    // log("Inside geometry factory function");
    return Geometry(
      coordinates: PolylinePoints()
          .decodePolyline(polyline)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
    );
  }
}

class Maneuver {
  final double bearing1;
  final double bearing2;
  final String? turnDirection;

  Maneuver({
    required this.bearing1,
    required this.bearing2,
    required this.turnDirection,
  });

  factory Maneuver.fromJson(Map<String, dynamic> json) {
    // log("Inside maneuver factory function");
    return Maneuver(
      bearing1: (json['bearing1'] as num).toDouble(),
      bearing2: (json['bearing2'] as num).toDouble(),
      turnDirection: json.containsKey("turn_direction")
          ? json['turn_direction'] as String?
          : null,
    );
  }
}

class Anomaly {
  final double longitude;
  final double latitude;
  final String category;

  Anomaly({
    required this.longitude,
    required this.latitude,
    required this.category,
  });

  factory Anomaly.fromJson(Map<String, dynamic> anomaly) {
    return Anomaly(
      longitude: (anomaly['longitude'] as num).toDouble(),
      latitude: (anomaly['latitude'] as num).toDouble(),
      category: anomaly['category'],
    );
  }
}

// This was what OSRM used to return, kept it here to support certain UI elements, kept these nullable until supported by the local server
class Leg {
  final List<Step>? steps;

  // You can add additional fields such as distance, duration, etc.
  final double distance;
  final double duration;

  Leg({
    required this.steps,
    required this.distance,
    required this.duration,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    // log("Inside leg factory function");
    return Leg(
      steps: null,
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
    // log("Inside step factory function");
    return Step(
      geometry: json['geometry'],
      maneuver: Maneuver.fromJson(json['maneuver']),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      name: json['name'] ?? "",
    );
  }
}
