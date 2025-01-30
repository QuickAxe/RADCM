import 'package:latlong2/latlong.dart';

import '../data/models/anomaly_marker.dart';

// normally this service will interact with the backend to fetch thee anomalies
// TODO: req markers based on current view
class AnomalyService {
  static final List<AnomalyMarker> anomalies = [
    AnomalyMarker(
        location: const LatLng(15.591181864471721, 73.81062185333096),
        category: "Speedbreaker"),
    AnomalyMarker(
        location: const LatLng(15.588822298730122, 73.81307154458827),
        category: "Rumbler"),
    AnomalyMarker(
        location: const LatLng(15.593873211033117, 73.81406673161777),
        category: "Obstacle"),
    AnomalyMarker(
        location: const LatLng(15.594893209859874, 73.80957563101596),
        category: "Speedbreaker"),
    AnomalyMarker(
        location: const LatLng(15.591304757805778, 73.80879734369576),
        category: "Rumbler"),
  ];
}
