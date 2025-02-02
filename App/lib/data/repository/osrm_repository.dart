import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/osrm_models.dart';

class OSRMRepository {
  final String baseUrl =
      "https://router.project-osrm.org/route/v1/driving"; // TODO: Allow users to select the mode

  Future<RouteResponse> fetchRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    bool alternatives = true,
    bool steps = true,
    String geometries = "polyline",
    String overview = "false",
    bool annotations = true,
  }) async {
    final String url =
        "$baseUrl/$startLng,$startLat;$endLng,$endLat?alternatives=$alternatives&steps=$steps&geometries=$geometries&overview=$overview&annotations=$annotations";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return RouteResponse.fromJson(jsonData);
    } else {
      throw Exception("Failed to load route data");
    }
  }
}
