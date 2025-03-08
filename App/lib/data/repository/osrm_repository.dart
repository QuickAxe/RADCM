import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/osrm_models.dart';

class OSRMRepository {
  final String localServerUrl =
      'http://${dotenv.env['IP_ADDRESS']}:8000/api/routes/';
  final String osrmBaseUrl = "http://router.project-osrm.org/match/v1/driving/";

  /// Fetches raw route polylines from local API, decodes them, and sends them to OSRM Matching API.
  Future<RouteResponse> fetchMatchedRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    log("\"$startLat, $startLng\"; \"$endLat, $endLng\"");
    final String localUrl =
        "$localServerUrl?format=json&latitudeEnd=$endLat&latitudeStart=$startLat&longitudeEnd=$endLng&longitudeStart=$startLng";

    final localResponse = await http.get(Uri.parse(localUrl));
    log("Called the local API: $localUrl");

    if (localResponse.statusCode != 200) {
      throw Exception("Failed to fetch data from local API");
    }

    final localData = json.decode(localResponse.body);

    // This basically stores the coordinates of all the routes
    final List<List<LatLng>> allRouteCoordinates =
        _extractCoordinates(localData);

    if (allRouteCoordinates.isEmpty) {
      throw Exception("No routes received");
    }

    // fetching the first route FOR NOW
    final List<LatLng> fullRoute = allRouteCoordinates.first;
    const int chunkSize = 5;
    List<Map<String, dynamic>> rawOsrmResponses = [];

    for (int i = 0; i < fullRoute.length; i += chunkSize) {
      final List<LatLng> chunk =
          fullRoute.sublist(i, (i + chunkSize).clamp(0, fullRoute.length));
      String coordinateStr = _formatCoordinates(chunk);

      log("Processing chunk ${i ~/ chunkSize + 1}: ${coordinateStr.length} chars");

      final osrmUrl =
          "$osrmBaseUrl$coordinateStr?steps=true&geometries=geojson&overview=full&annotations=false&tidy=true";
      log("Called $osrmUrl");
      final osrmResponse = await http.get(Uri.parse(osrmUrl));

      if (osrmResponse.statusCode != 200) {
        throw Exception(
            "Failed to fetch matched route from OSRM: ${osrmResponse.reasonPhrase}");
      }

      final Map<String, dynamic> osrmData = json.decode(osrmResponse.body);
      rawOsrmResponses.add(osrmData);
    }

    return _mergeOsrmResponses(rawOsrmResponses);
  }

  RouteResponse _mergeOsrmResponses(List<Map<String, dynamic>> responses) {
    if (responses.isEmpty) {
      throw Exception("No OSRM responses to merge.");
    }

    // Extract matchings from all responses
    List<dynamic> allMatchings =
        responses.expand((r) => r["matchings"] as List).toList();

    if (allMatchings.isEmpty) {
      throw Exception("No valid matchings found.");
    }

    // Merge matchings into one single matching object
    final mergedMatching = _mergeMatchings(allMatchings);

    // Construct the final merged JSON
    final mergedJson = {
      "code": responses.first["code"], // Keeping the same response code
      "matchings": [mergedMatching], // Wrap in a list since OSRM expects a list
    };

    return RouteResponse.fromJson(mergedJson);
  }

  Map<String, dynamic> _mergeMatchings(List<dynamic> matchings) {
    List<List<double>> mergedCoordinates = [];
    List<dynamic> mergedLegs = [];
    double totalWeight = 0;
    double totalDuration = 0;
    double totalDistance = 0;
    double maxConfidence = 0;

    for (var matching in matchings) {
      // Merge geometry coordinates
      mergedCoordinates.addAll((matching["geometry"]["coordinates"] as List)
          .map((e) => List<double>.from(e)));

      // Merge legs
      mergedLegs.addAll(matching["legs"] as List);

      // Sum up weight, duration, distance
      totalWeight += (matching["weight"] as num).toDouble();
      totalDuration += (matching["duration"] as num).toDouble();
      totalDistance += (matching["distance"] as num).toDouble();

      // Get max confidence
      maxConfidence = maxConfidence > (matching["confidence"] as num).toDouble()
          ? maxConfidence
          : (matching["confidence"] as num).toDouble();
    }

    return {
      "confidence": maxConfidence,
      "geometry": {"coordinates": mergedCoordinates, "type": "LineString"},
      "legs": mergedLegs,
      "weight_name": "routability",
      "weight": totalWeight,
      "duration": totalDuration,
      "distance": totalDistance
    };
  }

  /// Extracts coordinates by decoding polylines using flutter_polyline_points.
  List<List<LatLng>> _extractCoordinates(Map<String, dynamic> data) {
    List<List<LatLng>> extractedRoutes = [];
    final routes = data["routes"] ?? [];
    final polylinePoints = PolylinePoints();

    for (var route in routes) {
      List<LatLng> routeCoordinates = [];
      for (var segment in route) {
        if (segment.containsKey("polyline")) {
          List<PointLatLng> decoded =
              polylinePoints.decodePolyline(segment["polyline"]);
          List<LatLng> latLngList =
              decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

          routeCoordinates.addAll(latLngList);
        }
      }
      extractedRoutes.add(routeCoordinates);
    }
    // extractedRoutes is local to this function, its a [[LatLng]]
    return extractedRoutes;
  }

  /// Function to downsample a list of LatLng points by keeping every nth coordinate.
  List<LatLng> _downsampleCoordinates(List<LatLng> coordinates, int step) {
    if (coordinates.isEmpty || step <= 1) return coordinates;
    return [for (int i = 0; i < coordinates.length; i += step) coordinates[i]];
  }

  /// Formats a list of LatLng into the OSRM Matching API coordinate format.
  String _formatCoordinates(List<LatLng> coordinates) {
    return coordinates
        .map((coord) => "${coord.longitude},${coord.latitude}")
        .join(";");
  }
}
