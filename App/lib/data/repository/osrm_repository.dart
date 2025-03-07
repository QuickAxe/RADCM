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
    log("Called the local API");

    if (localResponse.statusCode != 200) {
      throw Exception("Failed to fetch data from local API");
    }

    final localData = json.decode(localResponse.body);

    // This basically stores the coordinates of all the routes
    final List<List<LatLng>> allRouteCoordinates =
        _extractCoordinates(localData);

    if (allRouteCoordinates.isEmpty) {
      throw Exception(
          "No valid coordinates found in response"); // TODO: Gracefully handle this
    }

    final List<LatLng> fullRoute = allRouteCoordinates.first;
    const int chunkSize = 5;
    List<RouteResponse> routeResponses = [];

    for (int i = 0; i < fullRoute.length; i += chunkSize) {
      final List<LatLng> chunk =
          fullRoute.sublist(i, (i + chunkSize).clamp(0, fullRoute.length));
      String coordinateStr = _formatCoordinates(chunk);
      log("Processing chunk ${i ~/ chunkSize + 1}: ${coordinateStr.length} chars");
      final osrmUrl =
          "$osrmBaseUrl$coordinateStr?steps=true&geometries=geojson&overview=full&annotations=false";
      final osrmResponse = await http.get(Uri.parse(osrmUrl));

      if (osrmResponse.statusCode != 200) {
        throw Exception(
            "Failed to fetch matched route from OSRM: ${osrmResponse.reasonPhrase}");
      }

      final osrmData = json.decode(osrmResponse.body);
      routeResponses.add(RouteResponse.fromJson(
          osrmData)); // These are multiple OSRM responses
    }

    return _mergeRouteResponses(routeResponses);
  }

  RouteResponse _mergeRouteResponses(List<RouteResponse> responses) {
    if (responses.isEmpty) {
      throw Exception("No RouteResponse objects inside responses to merge,");
    }

    // basically matching is the common thing in every route response from OSRM, so just merge it for all the responses
    List<MatchingModel> mergedMatchings =
        responses.expand((r) => r.matchings).toList();

    return RouteResponse(
      code: responses.first.code,
      matchings: mergedMatchings,
    );
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
