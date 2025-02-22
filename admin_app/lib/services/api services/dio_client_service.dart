import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();
  static String baseUrl = "http://${dotenv.env['IP_ADDRESS']}:8000/api/auth/";

  void logout() {
    storage.deleteAll();
  }

  DioClient() {
    dio.options.baseUrl = baseUrl;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await storage.read(key: 'access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          bool refreshed = await _refreshToken();
          if (refreshed) {
            final retryRequest = await dio.fetch(e.requestOptions);
            return handler.resolve(retryRequest);
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
      if (refreshToken == null) return false;

      final response = await dio.post("token/refresh/", data: {"refresh": refreshToken});
      if (response.statusCode == 200) {
        await storage.write(key: 'access_token', value: response.data['access']);
        await storage.write(key: 'refresh_token', value: response.data['refresh']);
        return true;
      }
    } catch (e) {
      print("Token refresh failed: $e");
      return false;
    }
    return false;
  }
}
