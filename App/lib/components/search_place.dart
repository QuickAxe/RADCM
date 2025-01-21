import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SearchPlace extends StatefulWidget {
  const SearchPlace({super.key, required this.mapController});
  final MapController mapController;

  @override
  State<SearchPlace> createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  List<dynamic> searchSuggestions = [];
  late SearchController _searchController;

  // Fetch multiple places for a search query
  Future<void> getSuggestions(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=50');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        searchSuggestions = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to fetch search results');
    }
    dev.log(searchSuggestions.toString());
  }

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
        LatLng loc =
            LatLng(double.parse(place['lat']), double.parse(place['lon']));
        userTapsSearchResult(
            place['display_name'] ?? 'Unknown Place', loc, controller);
      },
    );
  }

  void userTapsSearchResult(
      String displayName, LatLng loc, SearchController controller) {
    widget.mapController.move(loc, widget.mapController.camera.zoom);
    controller.closeView(displayName);
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        _searchController = controller;
        return SearchBar(
          controller: controller,
          onSubmitted: (_) async {
            await getSuggestions(controller.text.toString());
            dev.log(controller.text.toString());
            controller.openView();
          },
          trailing: const <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.search),
            )
          ],
          hintText: "Search Map",
          elevation: WidgetStateProperty.all(0), // Remove shadow
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(searchSuggestions.length, (int index) {
          dev.log(searchSuggestions[index].toString());
          return buildPlaceItem(searchSuggestions[index], controller);
        });
      },
      viewOnSubmitted: (_) async {
        await getSuggestions(_searchController.text.toString());
        dev.log(_searchController.text.toString());
        _searchController.openView();
      },
    );
  }
}
