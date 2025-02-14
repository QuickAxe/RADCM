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
    AnomalyMarker(
        location: const LatLng(15.584061447947198, 73.81146790457018),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.59596836458232, 73.81428333210658),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.596043959712947, 73.80842313068612),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.596837725149859, 73.83283584157593),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.582885891131836, 73.82594166944739),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.593081555399163, 73.80010593349097),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.58664224737931, 73.79989701918404),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.603075498043546, 73.81535667789652),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.423800121925453, 73.97964867378532),
        category: "Pothole"),
    AnomalyMarker(
        location: const LatLng(15.424183719267909, 73.97882496054558),
        category: "Pothole"),
  ];
}
