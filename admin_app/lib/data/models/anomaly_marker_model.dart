import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'anomaly_marker_model.g.dart';

@HiveType(typeId: 0)
class AnomalyMarker {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int cid;

  AnomalyMarker({
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.cid,
  });

  LatLng get location => LatLng(latitude, longitude);
}
