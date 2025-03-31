import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../util/general_utils.dart';

class Permissions extends ChangeNotifier with WidgetsBindingObserver {
  Position? _position;
  bool _locationAvailable = false;
  bool _loadingLocation = false;
  bool _waitingForLocationSettings = false;

  Position? get position => _position;
  bool get locationAvailable => _locationAvailable;
  bool get loadingLocation => _loadingLocation;

  Permissions() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForLocationSettings) {
      _waitingForLocationSettings = false;
      fetchPosition();
    }
  }

  Future<void> fetchPosition() async {
    _loadingLocation = true;
    notifyListeners();

    showToast("Fetching user location");

    if (!await Geolocator.isLocationServiceEnabled()) {
      dev.log('Location Service is disabled.');
      showToast("Enable location services in settings.");
      _waitingForLocationSettings = true;
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      dev.log('Location permission permanently denied.');
      showToast("Location permission denied. Enable it in settings.");
      await Geolocator.openAppSettings();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _position = await Geolocator.getCurrentPosition();
      _locationAvailable = true;
      _loadingLocation = false;
      notifyListeners();
    } else {
      dev.log('Location permission not granted.');
      _locationAvailable = false;
      _loadingLocation = false;
      notifyListeners();
    }
  }

  void startListening() {
    Geolocator.getPositionStream().listen((Position newPosition) {
      _position = newPosition;
      _locationAvailable = true;
      notifyListeners();
    });
  }
}
