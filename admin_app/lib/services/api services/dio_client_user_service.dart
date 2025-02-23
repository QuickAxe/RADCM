import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClientUser {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://${dotenv.env['IP_ADDRESS']}:8000/api/',
      connectTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // GET request
  Future<Response> getRequest(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  // POST request
  Future<Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  // PUT request
  Future<Response> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw Exception("Error updating data: $e");
    }
  }

  // DELETE request
  Future<Response> deleteRequest(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      throw Exception("Error deleting data: $e");
    }
  }
}
