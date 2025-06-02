import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../util/general_utils.dart';

class AnomalyWebSocketProvider extends ChangeNotifier with WidgetsBindingObserver {
  WebSocket? _socket;
  bool _isConnected = false;
  DateTime? _lastConnectAttempt;
  bool get isConnected => _isConnected;

  AnomalyWebSocketProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _socket?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // to prevent multiple websocket connections due to app resume
    if (state == AppLifecycleState.resumed && !_isConnected) {
      final now = DateTime.now();
      if (_lastConnectAttempt == null || now.difference(_lastConnectAttempt!) > Duration(seconds: 2)) {
        _lastConnectAttempt = now;
        connect();
      }
    }
  }

  void init() {
    connect();
  }

  Future<void> connect({int retry = 0}) async {
    await disconnect();

    try {
      _socket = await WebSocket.connect('wss://radcm.sorciermahep.tech/ws/anomaly_updates/');
      showToast("Websocket connected");

      _isConnected = true;
      notifyListeners();

      _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
      _isConnected = false;
      notifyListeners();

      if (e.toString().contains('Failed host lookup') && retry < 3) {
        await Future.delayed(Duration(seconds: 1));
        await connect(retry: retry + 1);
      }
    }
  }

  void _onData(dynamic data) {
    final message = json.decode(data)['message'];

    showToast("Websocket message: $message");
    if(message == 'anomalies_added' || message == 'anomalies_removed') {
      // handle anomaly re-fetch
      print('idk man keeping this empty didnt feel nice');
    }
  }

  void _onError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false;
    notifyListeners();
  }

  void _onDone() {
    print('WebSocket closed.');
    _isConnected = false;
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await _socket?.close();
      showToast("Websocket disconnected");
    } catch (_) {}
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  void send(String message) {
    _socket?.add(json.encode({'message': message}));
  }
}
