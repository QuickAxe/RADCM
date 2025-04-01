import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Search extends ChangeNotifier {
  List<dynamic> searchSuggestions = [];
  bool isCurrentSelected = false;
  bool loadingResults = false;
  dynamic currentSelected;
  String? errorMessage;

  // Fetch multiple places for a search query
  Future<void> getSuggestions(String query) async {
    loadingResults = true;
    errorMessage = null;
    notifyListeners();

    searchSuggestions.clear(); // clear previous search results

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=50');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        searchSuggestions = json.decode(response.body);
      } else {
        errorMessage = "Unexpected error: ${response.statusCode}";
      }
    } on SocketException {
      errorMessage = "No internet connection. Check your network.";
    } on TimeoutException {
      errorMessage = "Server timeout. Try again later.";
    } catch (e) {
      errorMessage = "An unexpected error occurred.";
    } finally {
      loadingResults = false;
      notifyListeners();
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
