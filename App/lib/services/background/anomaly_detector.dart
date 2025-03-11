import 'dart:async';
import 'dart:developer' as dev;

import 'package:app/services/api_service/dio_client_user_service.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart' as frs;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../data/models/bg_anomaly_model.dart';

class AnomalyDetector{
  late StreamSubscription? _anomalyDetectorSubscription;
  late bool _isBufferFlushing;

  AnomalyDetector(){
    _anomalyDetectorSubscription = null;
    _isBufferFlushing = false;
  }

  Future<void> startDetector() async {
    frs.Matrix3 rotationMatrix = frs.Matrix3(0, 0, 0, 0, 0, 0, 0, 0, 0);

    // the buffer that contains probable anomalies
    List<Anomaly> probableAnomalyBuffer = [];

    // the sliding window
    Anomaly currentWindow = Anomaly();

    // to set time delay between consecutive anomalies
    DateTime lastAnomaly = DateTime(2023, 12, 25, 0, 0, 0);

    // set sampling period for the guy that gives rotation matrix
    frs.RotationSensor.samplingPeriod = frs.SensorInterval.fastestInterval;

    // Combine streams to listen simultaneously
    _anomalyDetectorSubscription = CombineLatestStream.list([
      accelerometerEventStream(
          samplingPeriod: SensorInterval.fastestInterval), // Stream 0
      frs.RotationSensor.orientationStream, // Stream 1
      _getLocationUpdates(), // Stream 2
    ]).throttleTime(const Duration(milliseconds: 20)).listen((data) async {
      // don't listen to events while the current buffer is getting flushed
      if (_isBufferFlushing) return;

      // data[i] corresponds to the ith stream
      final accEvent = data[0] as AccelerometerEvent;
      final frsEvent = data[1] as frs.OrientationEvent;
      final locEvent = data[2] as Position;
      final now = DateTime.now();

      // if size is 200 then check the window for anomaly
      if (currentWindow.accReadings.length == 200 &&
          now.difference(lastAnomaly).inMilliseconds >= 5000) {
        bool isAnomaly =
        await _checkWindow(currentWindow, probableAnomalyBuffer, locEvent);
        if (isAnomaly) {
          lastAnomaly = DateTime.now();
        }
      }

      // read sensor data, reorient and push the entry to buffer
      rotationMatrix = frsEvent.rotationMatrix;
      List<double> accGlobal = _reorientAccelerometer(
          [accEvent.x, accEvent.y, accEvent.z], rotationMatrix);
      currentWindow.accReadings.add([accGlobal[0], accGlobal[1], accGlobal[2]]);

      // resize
      if (currentWindow.accReadings.length == 201) {
        currentWindow.accReadings.removeFirst();
      }
    });
  }

  void stopDetector() {
    _anomalyDetectorSubscription?.cancel();
    _anomalyDetectorSubscription = null;
  }

  // get location updates stream
  Stream<Position> _getLocationUpdates() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1, // Only trigger when moved 1 meter
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  // reorients accelerometer data using the rotation matrix
  List<double> _reorientAccelerometer(List<double> accLocal, frs.Matrix3 rotationMatrix) {
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

  // check if the read block is an anomaly
  Future<bool> _checkWindow(Anomaly currentWindow, List<Anomaly> probableAnomalyBuffer, Position position) async {
    double accelLeft = currentWindow.accReadings.elementAt(97)[2];
    double accelRight = currentWindow.accReadings.elementAt(103)[2];
    double threshold = 18.0;
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
      _isBufferFlushing = true;
      await _flushBuffer(probableAnomalyBuffer);
      _isBufferFlushing = false;
    }

    // currentWindow.accReadings.removeFirst();
    return isAnomaly;
  }

  // sends probable anomaly data to backend when it reaches buffer limit
  Future<void> _flushBuffer(List<Anomaly> probableAnomalyBuffer) async {
    // send data to backend..
    dev.log("Buffer Flushed.. ");

    dev.log('BEFORE ------------------------> ${DateTime.now()}');
    bool isSuccess = await _formatAndPost(probableAnomalyBuffer);
    dev.log('AFTER ------------------------> ${DateTime.now()}');

    probableAnomalyBuffer.clear();

    if (isSuccess) {
      Fluttertoast.showToast(
        msg: "Data sent successfully, buffer flushed!",
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Server issue: Couldn't send data, buffer flushed anyway",
        toastLength: Toast.LENGTH_LONG,
      );
    }

    return;
  }

  Future<bool> _formatAndPost(probableAnomalyBuffer) async {
    Map<String, dynamic> data = _formatAnomalyData(probableAnomalyBuffer);
    DioResponse response =
    await DioClientUser().postRequest('anomalies/sensors/', data);
    return response.success == true;
  }

  Map<String, dynamic> _formatAnomalyData(List<Anomaly> probableAnomalyBuffer) {
    List<dynamic> anomalyData = [];

    for (int i = 0; i < probableAnomalyBuffer.length; i++) {
      Anomaly anomaly = probableAnomalyBuffer[i];

      anomalyData.add({
        "latitude": anomaly.latitude,
        "longitude": anomaly.longitude,
        "window": anomaly.accReadings.toList(), // Convert ListQueue to List
      });
    }

    return {"source": "mobile", "anomaly_data": anomalyData};
  }

}