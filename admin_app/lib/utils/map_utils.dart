import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

Widget customDarkModeTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
      -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
      -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
      0, 0, 0, 1, 0, // Alpha channel
    ]),
    child: tileWidget,
  );
}

Widget mapMarkerIcon(String iconPath, Color shadowColor) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: shadowColor,
          //     blurRadius: 10,
          //     spreadRadius: 2,
          //     offset: const Offset(2, 3),
          //   ),
          // ],
        ),
      ),
      Image.asset(
        iconPath,
        width: 60.0,
        height: 60.0,
      ),
    ],
  );
}

/// Takes a LatLng and returns a formatted address string
Future<String> getAddress(LatLng location) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      return "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";
    }
  } catch (e) {
    return "Address not available";
  }
  return "Address not available";
}
