
import 'dart:async';

import 'package:app/services/background/anomaly_detector.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActivityTracker{
  StreamSubscription<Activity>? _activitySubscription;
  late bool _isAnomalyDetectorActive;
  late AnomalyDetector anomalyDetector;
  // TODO - handle wasted buffer

  ActivityTracker() {
    _activitySubscription = null;
    _isAnomalyDetectorActive = false;
    anomalyDetector = AnomalyDetector();
  }

  Future<void> startTracker() async {
    if (await _checkAndRequestPermission()) {
      _activitySubscription = FlutterActivityRecognition.instance.activityStream
          .handleError(_onError)
          .listen(_onActivity);
    }
  }

  void stopTracker() {
    _activitySubscription?.cancel();
    _activitySubscription = null;
  }

  void _onActivity(Activity activity) {
    print('activity detected >> ${activity.toJson()}');
    if((activity.type == ActivityType.IN_VEHICLE || activity.type == ActivityType.ON_BICYCLE) && !_isAnomalyDetectorActive && activity.confidence == ActivityConfidence.HIGH) {
      _isAnomalyDetectorActive = true;
      anomalyDetector.startDetector();

      Fluttertoast.showToast(
        msg: "${activity.type} - Anomaly Detector Active!",
        toastLength: Toast.LENGTH_LONG,
      );
    }
    else if (activity.confidence == ActivityConfidence.HIGH && _isAnomalyDetectorActive){
      _isAnomalyDetectorActive = false;
      anomalyDetector.stopDetector();

      Fluttertoast.showToast(
        msg: "${activity.type} - Anomaly Detector Inactive!",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _onError(dynamic error) {
    print('error >> $error');
  }

  Future<bool> _checkAndRequestPermission() async {
    ActivityPermission permission =
    await FlutterActivityRecognition.instance.checkPermission();
    if (permission == ActivityPermission.PERMANENTLY_DENIED) {
      // permission has been permanently denied.
      return false;
    } else if (permission == ActivityPermission.DENIED) {
      permission =
      await FlutterActivityRecognition.instance.requestPermission();
      if (permission != ActivityPermission.GRANTED) {
        // permission is denied.
        return false;
      }
    }

    return true;
  }
}