import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart' as frs;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';

// ----------------------------------- Represents the structure of an anomaly -----------------------------------------
class Anomaly {
  ListQueue<List<double>> accReadings = ListQueue();
  double latitude = 0.0;
  double longitude = 0.0;
}

// ----------------------------------- Heard abt tax collector? -------------------------------------------------------
// @pragma('vm:entry-point')
Future<void> theDataCollector() async {
  frs.Matrix3 rotationMatrix = frs.Matrix3(0, 0, 0, 0, 0, 0, 0, 0, 0);

  List<Anomaly> probableAnomalyBuffer =
      []; // the buffer that contains probable anomalies
  Anomaly currentWindow = Anomaly(); // the sliding window
  DateTime lastAnomaly = DateTime(2023, 12, 25, 0, 0, 0); // to set time delay between consecutive anomalies

  // set sampling period for the guy that gives rotation matrix
  frs.RotationSensor.samplingPeriod = frs.SensorInterval.fastestInterval;

  // Combine streams to listen simultaneously
  CombineLatestStream.list([
    accelerometerEventStream(
        samplingPeriod: SensorInterval.fastestInterval), // Stream 0
    frs.RotationSensor.orientationStream, // Stream 1
    getLocationUpdates(), // Stream 2
  ])
      .throttleTime(const Duration(milliseconds: 20))
      .listen((data) {
    // data[i] corresponds to the ith stream
    final accEvent = data[0] as AccelerometerEvent;
    final frsEvent = data[1] as frs.OrientationEvent;
    final locEvent = data[2] as Position;
    final now = DateTime.now();

    // if size is 200 then check the window for anomaly
    if (currentWindow.accReadings.length == 200 &&
        now.difference(lastAnomaly).inMilliseconds >= 5000) {
      bool isAnomaly = checkWindow(currentWindow, probableAnomalyBuffer, locEvent);
      if (isAnomaly) {
        lastAnomaly = DateTime.now();
      }
    }

    // read sensor data, reorient and push the entry to buffer
    rotationMatrix = frsEvent.rotationMatrix;

    List<double> accGlobal = reorientAccelerometer(
        [accEvent.x, accEvent.y, accEvent.z], rotationMatrix);

    currentWindow.accReadings.add([accGlobal[0], accGlobal[1], accGlobal[2]]);

    // resize
    if (currentWindow.accReadings.length == 201) {
      currentWindow.accReadings.removeFirst();
    }
  });
}

// ----------------------------------- Permission handling for lat, long ----------------------------------------------
// Future<void> requestPermissions() async {
//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // Handle permission denied
//       print('Location permissions are denied');
//     }
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     // Permissions are denied forever.
//     print(
//         'Location permissions are permanently denied, we cannot request permissions.');
//   }
// }

// ----------------------------------- Location Updates Stream --------------------------------------------------------
Stream<Position> getLocationUpdates() {
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 1, // Only trigger when moved 1 meter
  );

  return Geolocator.getPositionStream(
    locationSettings: locationSettings,
  );
}

// ----------------------------------- Reorients accelerometer data using the rotation matrix -------------------------
List<double> reorientAccelerometer(
    List<double> accLocal, frs.Matrix3 rotationMatrix) {
  // Multiply the rotation matrix by the accelerometer vector
  double xGlobal = rotationMatrix.a * accLocal[0] +
      rotationMatrix.b * accLocal[1] +
      rotationMatrix.c * accLocal[2];
  double yGlobal = rotationMatrix.d * accLocal[0] +
      rotationMatrix.e * accLocal[1] +
      rotationMatrix.f * accLocal[2];
  double zGlobal = rotationMatrix.g * accLocal[0] +
      rotationMatrix.h * accLocal[1] +
      rotationMatrix.i * accLocal[2];

  return [xGlobal, yGlobal, zGlobal];
}

// ----------------------------------- Checks if the read block is an anomaly -----------------------------------------
bool checkWindow(Anomaly currentWindow, List<Anomaly> probableAnomalyBuffer,
    Position position) {
  double accelLeft = currentWindow.accReadings.elementAt(97)[2];
  double accelRight = currentWindow.accReadings.elementAt(103)[2];
  double threshold = 12.0;
  int maxBufferSize = 5; // change this later
  bool isAnomaly = false;

  // check threshold for valid anomaly
  if ((accelLeft - accelRight).abs() >= threshold) {
    dev.log(
        "---------------------  Anomaly Encountered At Timestamp: ${DateTime.now()}  ---------------------");
    Fluttertoast.showToast(
      msg: "Anomaly detected at ${DateTime.now()}!",
      toastLength: Toast.LENGTH_LONG,
    );

    // update location
    currentWindow.latitude = position.latitude;
    currentWindow.longitude = position.longitude;

    probableAnomalyBuffer.add(currentWindow);
    isAnomaly = true;
  }

  if (probableAnomalyBuffer.length == maxBufferSize) {
    flushBuffer(probableAnomalyBuffer);
  }

  currentWindow.accReadings.removeFirst();
  return isAnomaly;
}

// ----------------------------------- When anomaly buffer has reached its limit and needs to be emptied --------------
void flushBuffer(List<Anomaly> probableAnomalyBuffer) {
  // send data to backend..
  dev.log("Buffer Flushed.. ");
  probableAnomalyBuffer.clear();
}
