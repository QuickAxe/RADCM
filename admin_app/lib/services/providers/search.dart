import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../api services/dio_client_user_service.dart';

class Search extends ChangeNotifier {
  List<dynamic> searchSuggestions = [];
  bool isCurrentSelected = false;
  bool loadingResults = false;
  dynamic currentSelected;
  String? errorMessage;
  final DioClientUser _dioClient = DioClientUser();

  void logout() {
    searchSuggestions.clear();
    isCurrentSelected = false;
    currentSelected = null;
    notifyListeners();
  }

  // Fetch multiple places for a search query
  Future<void> getSuggestions(String query) async {
    loadingResults = true;
    errorMessage = null;
    notifyListeners();

    searchSuggestions.clear(); // clear previous search results

    try {
      const String baseUrl = "https://nominatim.openstreetmap.org/";
      const String endpoint = "search";

      Map<String, dynamic> queryParams = {
        "q": query,
        "format": "json",
        "addressdetails": "1",
        "limit": "50",
      };

      // final url = Uri.parse(
      //     'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=50');
      // final response = await http.get(url);

      DioResponse response = await _dioClient.getRequest(endpoint,
          baseUrl: baseUrl, queryParams: queryParams);
      if (response.success) {
        searchSuggestions = response.data;
        print('search content ---------------------> ${searchSuggestions}');
      } else {
        errorMessage = "Unexpected error: ${response.errorMessage}";
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
