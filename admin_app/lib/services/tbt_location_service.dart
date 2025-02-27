import 'dart:async';

import 'package:geolocator/geolocator.dart';

class TbtLocationService {
  StreamSubscription<Position>? _posStream;

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  void cancelStream() {
    _posStream?.cancel();
  }
}
