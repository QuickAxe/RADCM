import 'package:dio/dio.dart';
import 'dio_client_auth_service.dart';

class AuthorityService {
  final DioClientAuth dioClient;

  // we already have sorage in dio client so we shall use that
  AuthorityService(this.dioClient);

  Future<bool> login(String username, String password) async {
    try {
      Response response = await dioClient.dio.post(
        "token/",
        data: {
          "username": username,
          "password": password
        },
      );

      if (response.statusCode == 200) {
        await dioClient.storage.write(key: "access_token", value: response.data["access"]);
        await dioClient.storage.write(key: "refresh_token", value: response.data["refresh"]);
        return true;
      }
    } catch (e) {
      print("Login failed: $e");
    }
    return false;
  }

  Future<bool> fixAnomaly(double latitude, double longitude) async {
    try {
      Response response = await dioClient.dio.delete(
        "anomaly/fixed/",
        data: {
          "latitude": latitude,
          "longitude": longitude
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("anomaly status update failed: $e");
    }
    return false;
  }


}
