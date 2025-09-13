// First, add this dependency to your pubspec.yaml:
// dependencies:
//   http: ^1.1.0
//   geolocator: ^10.1.0 (optional, for current location)

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kupan_business/controllers/details_controller.dart';

class AddressSearchBottomSheet extends StatefulWidget {
  final Function(String) onAddressSelected;

  const AddressSearchBottomSheet({
    Key? key,
    required this.onAddressSelected,
  }) : super(key: key);

  @override
  State<AddressSearchBottomSheet> createState() => _AddressSearchBottomSheetState();
}

class _AddressSearchBottomSheetState extends State<AddressSearchBottomSheet> {

  DetailsController detailsController = Get.find();

  final TextEditingController _searchController = TextEditingController();
  List<PlaceResult> _searchResults = [];
  bool _isLoading = false;

  // Replace with your Google Places API key
  static const String _apiKey = 'AIzaSyBM8qkgYFZ9ED3vjoHTCOSJ8Km8cw1i4aU';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Using Google Places Autocomplete API with focus on India
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
              'input=${Uri.encodeComponent(query)}&'
              'components=country:in&'
              'key=$_apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response:::$data");
        final predictions = data['predictions'] as List;

        setState(() {
          _searchResults = predictions
              .map((prediction) => PlaceResult.fromJson(prediction))
              .toList();
        });
      }
    } catch (e) {
      print('Error searching places: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Search Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for area, city, or landmark',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              onChanged: (value) {
                // Debounce search to avoid too many API calls
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_searchController.text == value) {
                    _searchPlaces(value);
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start typing to search for addresses',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  title: Text(
                    result.mainText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    result.secondaryText,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    // print("Address::::${result.mainText}");
                    // widget.onAddressSelected(result.description);
                    final latLng = await _getPlaceDetails(result.placeId);
                    if (latLng != null) {
                      // print("Selected Address: ${result.description}");
                      // print("Lat: ${latLng['lat']}, Lng: ${latLng['lng']}");

                      // widget.onAddressSelected(result.description, latLng['lat'], latLng['lng']);
                      detailsController.getAddressFromLatLong(latLng['lat'], latLng['lng']);
                      // List<Placemark> placemarks = await placemarkFromCoordinates(
                      //   latLng['lat'],
                      //   latLng['lng'],
                      // );
                      // Placemark place = placemarks[0];
                      Navigator.pop(context);
                    }
                    // Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?'
            'place_id=$placeId&fields=geometry&key=$_apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
        };
      }
    }
    return null;
  }
}

class PlaceResult {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceResult({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};

    return PlaceResult(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? json['description'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }


}