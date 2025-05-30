import 'dart:developer';

import 'package:dio/dio.dart';

class DioResponse {
  final bool success;
  final dynamic data;
  final String? errorMessage;

  DioResponse({required this.success, this.data, this.errorMessage});
}

class DioClientUser {
  static final DioClientUser _instance = DioClientUser._internal();
  final Dio _dio;

  factory DioClientUser() => _instance;

  DioClientUser._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://radcm.sorciermahep.tech/api/',
            connectTimeout: const Duration(seconds: 10),
            // headers: {
            //   'Content-Type': 'application/json',
            // },
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        log("Request Method: ${options.method} ${options.uri}");
        log("Headers: ${options.headers}");
        log("Body: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("Response Code: ${response.statusCode}");
        log("Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log("Error Codee/Msg: ${e.response?.statusCode} ${e.message}");
        log("Response Data: ${e.response?.data}");
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio; //exposes the single dio instance

  // GET request
  Future<DioResponse> getRequest(String endpoint,
      {String? baseUrl, Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await _dio.get(
          Uri.parse(baseUrl ?? _dio.options.baseUrl)
              .resolve(endpoint)
              .toString(),
          queryParameters: queryParams);
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
    String endpoint,
    dynamic data, {
    String? baseUrl,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // print('baseUrl ----> $baseUrl');
      // print('optns baseUrl ----> ${_dio.options.baseUrl}');
      Response response = await _dio.post(
        Uri.parse(baseUrl ?? _dio.options.baseUrl).resolve(endpoint).toString(),
        data: data,
        onSendProgress: onSendProgress,
      );
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(
          success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }

  // PUT request
  Future<DioResponse> putRequest(String endpoint, Map<String, dynamic> data,
      {String? baseUrl}) async {
    try {
      Response response = await _dio.put(
          Uri.parse(baseUrl ?? _dio.options.baseUrl)
              .resolve(endpoint)
              .toString(),
          data: data);
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(
          success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }

  // DELETE request
  Future<DioResponse> deleteRequest(String endpoint, {String? baseUrl}) async {
    try {
      Response response = await _dio.delete(
        Uri.parse(baseUrl ?? _dio.options.baseUrl).resolve(endpoint).toString(),
      );
      return DioResponse(success: true, data: response.data);
    } on DioException catch (e) {
      return DioResponse(
          success: false, errorMessage: e.response?.statusMessage ?? e.message);
    } catch (e) {
      return DioResponse(success: false, errorMessage: "Unexpected error: $e");
    }
  }
}
