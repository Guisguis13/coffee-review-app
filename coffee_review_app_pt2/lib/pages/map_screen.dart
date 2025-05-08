import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../widgets/reviews_list_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
/// This widget is used to show a map screen with coffee shops
class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _center = const LatLng(53.546100, -113.493700); // edmonton location
  Set<Marker> _markers = {};
  bool _loadingLocation = true;

  final String googleApiKey = 'AIzaSyCYDiYJCDx41yON6iAeMx_nP6JqFHiMwVM';

  @override
  void initState() {
    super.initState();
    _determinePositionAndLoad();
  }

  Future<void> _determinePositionAndLoad() async {
    // Check permission
    bool permissionGranted = await _checkPermission();
    if (!permissionGranted) {
      setState(() => _loadingLocation = false);
      return; // Could not get location permission
    }

    // Permission granted, get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _loadingLocation = false;
    });

    // Now load coffee shops near that position
    await _loadCoffeeShops();
  }

  // Checks (and requests if necessary) the location permission
  //eturns true if permission is granted
  Future<bool> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    // Permission granted
    return true;
  }

  /// Calls the Nearby Places API to fetch coffee shops near _center
  // doesnt work for real location but will work if deployed to a real device
  // apparently the emulator does not have a location
  Future<void> _loadCoffeeShops() async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=${_center.latitude},${_center.longitude}'
        '&radius=5000&type=cafe&keyword=coffee&key=$googleApiKey';
    // 5km radius, type=cafe, keyword=coffee
    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['results'] == null) return;
      final List<dynamic> results = data['results'];
      // show the results on the map
      // convert the results to a set of markers
      // each marker has a unique id, position, and info window
      // info window has a title and a snippet
      // when the info window is tapped, show a dialog with the rating dialog
      final markers = results.map((shop) {
        final loc = shop['geometry']['location'];
        return Marker(
          markerId: MarkerId(shop['place_id']),
          position: LatLng(loc['lat'], loc['lng']),
          infoWindow: InfoWindow(
            title: shop['name'],
            snippet: shop['vicinity'] ?? '',
            onTap: () => showDialog(
              context: context,
              // shows list of reviews for the shop
              builder: (_) => ReviewsListDialog(
                placeId: shop['place_id'],
                placeName: shop['name'],
              ),
            ),
          ),
        );
      }).toSet();

      setState(() => _markers = markers);
    } catch (e) {
      debugPrint("Error loading coffee shops: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching location
    if (_loadingLocation) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Show map with coffee shops
    // if the user has not given permission to access location, show a message
    return Scaffold(
      appBar: AppBar(
        title: const Text("One Sip Coffee Reviews"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14,
        ),
        myLocationEnabled: true,       // shows user location
        myLocationButtonEnabled: true, // locate me button
        markers: _markers,
        onMapCreated: (controller) => _controller = controller,
      ),
    );
  }
}
