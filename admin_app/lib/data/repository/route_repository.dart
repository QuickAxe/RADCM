import 'dart:developer';

import '../../services/api services/dio_client_user_service.dart';
import '../models/route_models.dart';

class RouteRepository {
  final DioClientUser _dioClient = DioClientUser();

  Future<RouteResponse> fetchRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    log("\"$startLat, $startLng\" → \"$endLat, $endLng\"");

    final response = await _dioClient.getRequest("routes/", queryParams: {
      "format": "json",
      "latitudeStart": startLat,
      "longitudeStart": startLng,
      "latitudeEnd": endLat,
      "longitudeEnd": endLng,
    });

    if (response.success) {
      return RouteResponse.fromJson(response.data);
    } else {
      throw Exception("Failed to fetch route: ${response.errorMessage}");
    }
  }
}
