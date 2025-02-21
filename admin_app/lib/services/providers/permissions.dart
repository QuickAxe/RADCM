import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class Permissions extends ChangeNotifier with WidgetsBindingObserver {
  Position? position;
  bool locationAvailable = false;
  bool waitingForLocationSettings = false;

  // This is used to observe lifecycle changes for the app so when it returns from the settings screen we can detect it
  Permissions() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void logout() {
    position = null;
    locationAvailable = false;
    waitingForLocationSettings = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && waitingForLocationSettings) {
      waitingForLocationSettings = false;
      // once u return from the settings screen call fetch position again
      fetchPosition();
    }
  }

  Future<void> fetchPosition() async {
    // checks if location is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    dev.log('I AM IN FETCH POSITION 1');

    if (!serviceEnabled) {
      dev.log('I AM IN FETCH POSITION 2');

      dev.log('Location Service not enabled.');
      locationAvailable = false;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "Location service is disabled. Please enable it in settings.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );

      waitingForLocationSettings = true;
      // opens location settings
      await Geolocator.openLocationSettings();
    }

    dev.log('I AM IN FETCH POSITION 3');
    await checkAndRequestLocationPermission();
  }

  Future<void> checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    dev.log('I AM IN CHECK & REQUEST 1');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        dev.log('Location permission was denied.');

        Fluttertoast.showToast(
          msg:
              "Location permission is denied. Please enable it in app settings.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        // opens app settings
        await Geolocator.openAppSettings();
      }
    }

    dev.log('I AM IN CHECK & REQUEST 2');

    // fetches the current position
    position = await Geolocator.getCurrentPosition();
    locationAvailable = true;
    notifyListeners();

    // checkBatteryOptimizationStatus();
  }

  // Future<void> checkBatteryOptimizationStatus() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // ?? syntax is basically to return a fallback value, in our case false
  //   bool batteryPromptShown = prefs.getBool("battery_prompt_shown") ?? false;
  //
  //   if (!batteryPromptShown) {
  //     await batteryOptimizationDisable();
  //     await prefs.setBool("battery_prompt_shown", true);
  //   }
  // }
  //
  // Future<void> batteryOptimizationDisable() async {
  //   if (Platform.isAndroid) {
  //     Fluttertoast.showToast(
  //       msg: "Please disable battery optimization.",
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //
  //     const intent = AndroidIntent(
  //       action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
  //       data: 'package:com.example.app',
  //       flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
  //     );
  //
  //     await intent.launch();
  //   }
  // }

  void startListening() {
    Geolocator.getPositionStream().listen(
      (Position newPosition) {
        position = newPosition;
        locationAvailable = true;
        notifyListeners();
      },
    );
  }
}
