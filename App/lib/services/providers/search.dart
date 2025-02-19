import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Search extends ChangeNotifier {
  List<dynamic> searchSuggestions = [];
  bool isCurrentSelected = false;
  bool loadingResults = false;
  dynamic currentSelected;

  // Fetch multiple places for a search query
  Future<void> getSuggestions(String query) async {
    loadingResults = true;
    notifyListeners();

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=50');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      searchSuggestions = json.decode(response.body);
      loadingResults = false;
      notifyListeners();
    } else {
      loadingResults = false;
      notifyListeners();
      throw Exception('Failed to fetch search results');
    }

  }

  void performSelection(dynamic place) {
    isCurrentSelected = true;
    currentSelected = place;
    notifyListeners();
  }

  void performDeselection() {
    isCurrentSelected = false;
    currentSelected = null;
    notifyListeners();
  }
}