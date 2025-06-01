import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../util/general_utils.dart';

class AnomalyWebSocketService {
  WebSocket? _socket;

  Future<void> connect() async {
    try {
      _socket = await WebSocket.connect('wss://radcm.sorciermahep.tech/ws/anomaly_updates/');

      showToast("Websocket connected!");

      _socket!.listen(
        (data) {
          print('Received: $data');
          final decoded = json.decode(data);
          final message = decoded['message'];

          showToast('WebSocket message recieved: $message');
          if(message == 'anomalies_added' || message == 'anomalies_removed') {
            // handle anomaly re-fetch
            print('idk man keeping this empty didnt feel nice');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket closed.');
        },
      );

      print("WebSocket connected.");
    } catch (e) {
      print('Connection error: $e');
    }
  }

  void sendMessage(String message) {
    if (_socket != null) {
      _socket!.add(json.encode({'message': message}));
    }
  }

  void disconnect() {
    _socket?.close();
  }
}
