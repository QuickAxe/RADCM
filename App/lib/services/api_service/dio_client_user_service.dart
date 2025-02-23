import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioResponse {
  final bool success;
  final dynamic data;
  final String? errorMessage;

  DioResponse({required this.success, this.data, this.errorMessage});
}


class DioClientUser {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://${dotenv.env['IP_ADDRESS']}:8000/api/',
      connectTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // GET request
  Future<DioResponse> getRequest(String endpoint) async {
    try {
      Response response = await _dio.get(endpoint);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }

  // POST request
  Future<DioResponse> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }

  // PUT request
  Future<DioResponse> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.put(endpoint, data: data);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(success: false, errorMessage: e.response?.statusMessage ?? e.message);
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
      return DioResponse(success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }
}
