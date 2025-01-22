import 'package:latlong2/latlong.dart';

// model for the anomaly marker (NOT to be confused with the Anomaly class from bg process)
class AnomalyMarker {
  final LatLng location;
  final String category;

  AnomalyMarker({required this.location, required this.category});
}
