import 'package:latlong2/latlong.dart';

// Map
const double defaultZoom = 18.0;
const double maxZoom = 20.0;
const double minZoom = 3.0;
const LatLng defaultCenter = LatLng(15.4961, 73.8264);
const double zoomThreshold = 10.0;

// Tiling server
const String tileServerUrl = 'https://tileserver.sorciermahep.tech/tile/{z}/{x}/{y}.png';
