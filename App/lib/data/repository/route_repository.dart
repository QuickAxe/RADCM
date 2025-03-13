import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/route_models.dart';

/// Handles fetching and processing route data from the local server.
class RouteRepository {
  late final Dio _dio;

  RouteRepository() {
    _dio = Dio(
      // Certain options are commented out, this was for me cuz i use NGROK sometimes, ignore it
      BaseOptions(
        baseUrl: 'http://${dotenv.env['IP_ADDRESS']}:8000/api/routes/',
        // baseUrl:
        //     'https://0b81-2a09-bac1-36a0-eb0-00-dd-21.ngrok-free.app/api/routes/',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Accept': 'application/json',
        //   'ngrok-skip-browser-warning': 'true',
        // },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        log("Sending Request: ${options.method} ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("Response Received: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log("Dio Error: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  /// Fetches route data from the local server.
  Future<RouteResponse> fetchRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    log("\"$startLat, $startLng\" → \"$endLat, $endLng\"");

    final response = await _dio.get("", queryParameters: {
      "format": "json",
      "latitudeStart": startLat,
      "longitudeStart": startLng,
      "latitudeEnd": endLat,
      "longitudeEnd": endLng,
    });
    return RouteResponse.fromJson(response.data);
  }
}
