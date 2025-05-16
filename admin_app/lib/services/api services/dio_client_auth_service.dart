import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClientAuth {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://radcm.sorciermahep.tech/api/",
      connectTimeout: const Duration(seconds: 5), // Connection timeout
    ),
  );

  final storage = const FlutterSecureStorage();

  Future<void> logout() async {
    await storage.deleteAll();
  }

  DioClientAuth() {
    bool triedOnce = false;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await storage.read(key: 'access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.type == DioExceptionType.connectionTimeout) {
          print("Connection timeout, please try again.");
        } else if (triedOnce) {
          print("Tried to refresh once, aborting.");
          return handler.reject(e);
        } else if (e.response?.statusCode == 401) {
          triedOnce = true;
          bool refreshed = await _refreshToken();
          if (refreshed) {
            final retryRequest = await dio.fetch(e.requestOptions);
            return handler.resolve(retryRequest);
          } else {
            return handler.reject(e); // Stop further retries
          }
        }
        return handler.next(e);
      },
    ));

    dio.interceptors.add(LogInterceptor(responseBody: true)); // Debug logging
  }

  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return false;
      }

      final response =
          await dio.post("token/refresh/", data: {"refresh": refreshToken});

      // print("Refresh Token Response: ${response.statusCode} - ${response.data}");

      if (response.statusCode == 200) {
        await storage.write(
            key: 'access_token', value: response.data['access']);
        await storage.write(
            key: 'refresh_token', value: response.data['refresh']);
        return true;
      }
    } catch (e) {
      print("Token refresh failed: $e");
    }
    return false;
  }
}
