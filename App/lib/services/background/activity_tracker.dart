import 'dart:async';
import 'dart:developer' as dev;

import 'package:app/services/background/anomaly_detector.dart';
import 'package:app/util/general_utils.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../data/models/bg_anomaly_model.dart';

class ActivityTracker {
  StreamSubscription<Activity>? _activitySubscription;
  late bool _isAnomalyDetectorActive;
  late AnomalyDetector _anomalyDetector;
  late List<Anomaly> _probableAnomalyBuffer;
  late DateTime _checkpoint;

  ActivityTracker() {
    _activitySubscription = null;
    _isAnomalyDetectorActive = false;
    _probableAnomalyBuffer = [];
    _anomalyDetector = AnomalyDetector(_probableAnomalyBuffer);
    _checkpoint = DateTime(2023, 12, 25, 0, 0, 0);
  }

  Future<void> startTracker() async {
    if (await _checkAndRequestPermission()) {
      _activitySubscription = FlutterActivityRecognition.instance.activityStream
          .handleError(_onError)
          .listen(_onActivity);
      dev.log("Activity Tracker subscription started.");
    } else {
      dev.log("activity perms not granted.");
    }
  }

  void stopTracker() {
    _activitySubscription?.cancel();
    _activitySubscription = null;
  }

  // its enforced that you have to stay in vehicle or idle mode for at least 5 seconds
  void _onActivity(Activity activity) {
    showToast('activity detected >> ${activity.toJson()}');

    if ((activity.type == ActivityType.IN_VEHICLE ||
            activity.type == ActivityType.ON_BICYCLE) &&
        !_isAnomalyDetectorActive &&
        activity.confidence != ActivityConfidence.LOW &&
        DateTime.now().difference(_checkpoint).inSeconds >= 5) {
      _isAnomalyDetectorActive = true;
      _checkpoint = DateTime.now();
      _anomalyDetector.startDetector();

      Fluttertoast.showToast(
        msg: "${activity.type} - Anomaly Detector Active!",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (!(activity.type == ActivityType.IN_VEHICLE ||
            activity.type == ActivityType.ON_BICYCLE) &&
        activity.confidence == ActivityConfidence.HIGH &&
        _isAnomalyDetectorActive &&
        DateTime.now().difference(_checkpoint).inSeconds >= 5) {
      _isAnomalyDetectorActive = false;
      _checkpoint = DateTime.now();

      // send data to backend if any
      if (_probableAnomalyBuffer.isNotEmpty) {
        _anomalyDetector.flushBuffer();
      }

      _anomalyDetector.stopDetector();

      Fluttertoast.showToast(
        msg: "${activity.type} - Anomaly Detector Inactive!",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _onError(dynamic error) {
    showToast('error >> $error');
  }

  Future<bool> _checkAndRequestPermission() async {
    showToast("Checking activity permission");
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
