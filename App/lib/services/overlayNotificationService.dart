import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class OverlayNotificationService {
  static final OverlayNotificationService _instance =
      OverlayNotificationService._internal();

  factory OverlayNotificationService() {
    return _instance;
  }

  OverlayNotificationService._internal();

  OverlaySupportEntry? _overlayEntry;

  void showNotification(String message) {
    _overlayEntry?.dismiss();
    _overlayEntry = showSimpleNotification(
      Text(message),
      background: Colors.yellowAccent,
      leading: const Icon(Icons.warning, color: Colors.black87),
      duration: const Duration(seconds: 10),
    );
  }

  void dismissNotification() {
    _overlayEntry?.dismiss();
    _overlayEntry = null;
  }
}
