import 'dart:convert';
import 'dart:developer' as dev;

import 'package:app/services/providers/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class SearchPlace extends StatefulWidget {
  final MapController mapController;

  const SearchPlace({super.key, required this.mapController});

  @override
  State<SearchPlace> createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  late SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
  }

  // returns a single suggestion ListTile
  ListTile buildPlaceItem(dynamic place, SearchController controller) {
    return ListTile(
      title: Text(
        place['display_name'] ?? 'Unknown Place',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        place['address']?['country'] ?? 'Address not available',
      ),
      leading: const Icon(Icons.location_on, color: Colors.blue),
      onTap: () {
        userTapsSearchResult(place, controller);
      },
    );
  }

  void userTapsSearchResult(dynamic place, SearchController controller) {
    LatLng loc = LatLng(double.parse(place['lat']), double.parse(place['lon']));
    Provider.of<Search>(context, listen: false).performSelection(place);
    widget.mapController.move(loc, widget.mapController.camera.zoom);
    controller.closeView(place['display_name']);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Search>(builder: (context, search, child) {
      return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          _searchController = controller;
          return SearchBar(
            controller: controller,
            onSubmitted: (_) async {
              await search.getSuggestions(controller.text.toString());
              controller.openView();
            },
            trailing: [
              IconButton(
                  onPressed: () {
                    controller.openView();
                  },
                  icon: const Icon(Icons.search)),
            ],
            hintText: "Search Map",
            elevation: WidgetStateProperty.all(0), // Remove shadow
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          List<ListTile> suggestions = search.searchSuggestions
              .map((place) => buildPlaceItem(place, controller))
              .toList();

          dev.log('Total search results: ${suggestions.length}');

          return suggestions;
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