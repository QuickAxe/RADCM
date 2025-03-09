import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/route_models.dart';

/// Handles fetching and processing route data from the local server.
class RouteRepository {
  final String localServerUrl =
      'http://${dotenv.env['IP_ADDRESS']}:8000/api/routes/';

  /// Fetches route data from the local server.
  Future<RouteResponse> fetchRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    log("\"$startLat, $startLng\" → \"$endLat, $endLng\"");
    final String url =
        "$localServerUrl?format=json&latitudeEnd=$endLat&latitudeStart=$startLat&longitudeEnd=$endLng&longitudeStart=$startLng";

    final response = await http.get(Uri.parse(url));
    log("Called Local API: $url");

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to fetch data from local API : ${response.reasonPhrase}");
    }

    final Map<String, dynamic> data = json.decode(response.body);
    log(data.runtimeType.toString());

    // Convert JSON response to RouteResponse object
    return RouteResponse.fromJson(data);
  }
}
