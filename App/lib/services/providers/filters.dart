import 'package:flutter/material.dart';

class Filters extends ChangeNotifier {
  final List<String> _filters = [
    "All",
    "Speedbreakers",
    "Rumblers",
    "Obstacles",
    "Rumblers",
  ];
  List<String> get filters =>
      _filters; // exposeds this list so we can access it outside
  String _selectedFilter = "All";
  String get selectedFilter => _selectedFilter;

  void setFilter(String? filter) {
    if (filter == null || filter == "All") {
      _selectedFilter = "All";
    } else {
      _selectedFilter = filter;
    }
    notifyListeners();
  }
}
