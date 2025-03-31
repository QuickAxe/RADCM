import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';

/// This class provides a single mapController to the entire app, to avoid unncexsary prop drilling
class MapControllerProvider extends ChangeNotifier {
  final MapController _mapController = MapController();

  MapController get mapController => _mapController;
}
