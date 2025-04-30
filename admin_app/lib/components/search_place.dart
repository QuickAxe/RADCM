import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../services/providers/search.dart';

class SearchPlace extends StatefulWidget {
  final MapController mapController;

  const SearchPlace({super.key, required this.mapController});

  @override
  State<SearchPlace> createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  late SearchController _searchController;

  /// Initializes the Search Controller
  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
  }

  /// Callback when user taps a search result
  void userTapsSearchResult(dynamic place, SearchController controller) {
    dev.log(place.toString());

    Provider.of<Search>(context, listen: false).performSelection(place);

    // Fits the currently selected place on the screen
    LatLngBounds bounds = LatLngBounds(
      LatLng(double.parse(place['boundingbox'][0]),
          double.parse(place['boundingbox'][2])),
      LatLng(double.parse(place['boundingbox'][1]),
          double.parse(place['boundingbox'][3])),
    );

    widget.mapController.fitCamera(CameraFit.bounds(bounds: bounds));
    widget.mapController.rotate(0);
    controller.closeView(place['display_name']);
  }

  Future<void> _performSearch(Search search) async {
    FocusScope.of(context).unfocus(); // Hide keyboard

    await search.getSuggestions(_searchController.text.trim());

    if (search.errorMessage != null) {
      _showErrorSnackbar(search.errorMessage!);
    } else if (search.searchSuggestions.isEmpty) {
      _showErrorSnackbar("No results found.");
    } else {
      _searchController.openView();
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // hello darkness
    return Consumer<Search>(builder: (context, search, child) {
      return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          _searchController = controller;
          return search.loadingResults
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Theme.of(context).hintColor,
                    size: 65,
                  ),
                )
              : SearchBar(
                  controller: controller,
                  onSubmitted: (_) async => await _performSearch(search),
                  trailing: [
                    IconButton(
                      onPressed: () async => await _performSearch(search),
                      icon: const Icon(Icons.search),
                    ),
                  ],
                  hintText: "Search Map",
                  elevation: WidgetStateProperty.all(0),
                );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          return search.searchSuggestions
              .map((place) => ListTile(
                    title: Text(
                      place['display_name'] ?? 'Unknown Place',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      place['address']?['country'] ?? 'Address not available',
                    ),
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    onTap: () => userTapsSearchResult(place, controller),
                  ))
              .toList();
        },
        viewOnSubmitted: (_) async {
          await search.getSuggestions(_searchController.text.toString());
          _searchController.closeView(_searchController.text.toString());
          _searchController.openView();
        },
      );
    });
  }
}
