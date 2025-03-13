import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioResponse {
  final bool success;
  final dynamic data;
  final String? errorMessage;

  DioResponse({required this.success, this.data, this.errorMessage});
}

// Certain options are commented out, this was for me cuz i use NGROK sometimes, ignore it
class DioClientUser {
  static final DioClientUser _instance = DioClientUser._internal();
  final Dio _dio;
  factory DioClientUser() => _instance;

  DioClientUser._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://${dotenv.env['IP_ADDRESS']}:8000/api/',
            // baseUrl: 'https://0b81-2a09-bac1-36a0-eb0-00-dd-21.ngrok-free.app/api/',
            connectTimeout: const Duration(seconds: 5),
            headers: {
              'Content-Type': 'application/json',
              //   'Accept': 'application/json',
              //   'ngrok-skip-browser-warning': 'true',
            },
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        log("Request: ${options.method} ${options.uri}");
        log("Headers: ${options.headers}");
        log("Body: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("Response: ${response.statusCode}");
        log("Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log("Error: ${e.response?.statusCode} ${e.message}");
        log("Response Data: ${e.response?.data}");
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio; //exposes the single dio instance

  // GET request
  Future<DioResponse> getRequest(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      Response response =
          await _dio.get(endpoint, queryParameters: queryParams);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(
          success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }

  // POST request
  Future<DioResponse> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(
          success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }

  // PUT request
  Future<DioResponse> putRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.put(endpoint, data: data);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(
          success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }

  // DELETE request
  Future<DioResponse> deleteRequest(String endpoint) async {
    try {
      Response response = await _dio.delete(endpoint);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(
          success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }
}
