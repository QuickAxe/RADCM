import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/osrm_models.dart';

class OSRMRepository {
  final String localServerUrl =
      'http://${dotenv.env['IP_ADDRESS']}:8000/api/navigation/routes/';
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
    // log("LocalData: $localData");

    // This basically stores the coordinates of all the routes
    final List<List<LatLng>> allRouteCoordinates =
        _extractCoordinates(localData);

    if (allRouteCoordinates.isEmpty) {
      throw Exception("No valid coordinates found in response");
    }

    // Format the coordinates for OSRM Matching API
    // TODO: Takes only the first route for now, change later to incorporate multiple routes
    String coordinateStr = _formatCoordinates(
        allRouteCoordinates.isNotEmpty ? allRouteCoordinates.first : []);
    log("Length Coordinates String: ${coordinateStr.length}");

    // Call OSRM Matching API
    final osrmUrl =
        "$osrmBaseUrl$coordinateStr?steps=true&geometries=geojson&overview=full&annotations=false";
    final osrmResponse = await http.get(Uri.parse(osrmUrl));

    if (osrmResponse.statusCode != 200) {
      throw Exception(
          "Failed to fetch matched route from OSRM: ${osrmResponse.reasonPhrase}");
    }

    final osrmData = json.decode(osrmResponse.body);
    log("OSRM Data length: ${osrmData.length}");

    return RouteResponse.fromJson(osrmData);
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
      routeCoordinates = _downsampleCoordinates(routeCoordinates, 5);
      log("Downsampled coordinates length: ${routeCoordinates.length.toString()}");
      extractedRoutes.add(routeCoordinates);
    }

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
