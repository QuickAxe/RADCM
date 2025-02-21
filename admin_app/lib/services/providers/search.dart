import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Search extends ChangeNotifier {
  List<dynamic> searchSuggestions = [];
  bool isCurrentSelected = false;
  dynamic currentSelected;

  void logout() {
    searchSuggestions.clear();
    isCurrentSelected = false;
    currentSelected = null;
    notifyListeners();
  }

  // Fetch multiple places for a search query
  Future<void> getSuggestions(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=50');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      searchSuggestions = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Failed to fetch search results');
    }

    // dev.log(searchSuggestions.toString());
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