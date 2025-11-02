import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng collegeLocation = LatLng(19.1076, 72.8375); // DJ Sanghvi College
  String selectedCategory = 'Restaurants';
  final MapController _mapController = MapController();

  final Map<String, List<Map<String, dynamic>>> nearbyPlaces = {
    'Restaurants': [
      {'name': 'Udupi 2 Mumbai', 'lat': 19.108044, 'lng': 72.838687},
      {'name': 'Anand Stall', 'lat': 19.103177, 'lng': 72.836779},
      {'name': 'Amar Juice Centre', 'lat': 19.109422, 'lng': 72.836809},
      {'name': 'Papillon Fast Food Corner', 'lat': 19.108095, 'lng': 72.838440},
      {'name': 'Starbucks', 'lat': 19.104593, 'lng': 72.836633},
      {'name': 'Genz Adda', 'lat': 19.103637, 'lng': 72.837053},
      {'name': "McDonald's", 'lat': 19.108253, 'lng': 72.839998},
      {'name': 'Naturals Ice Creams', 'lat': 19.111685, 'lng': 72.837767},
    ],
    'Fun & Entertainment': [
      {'name': 'Prime Mall', 'lat': 19.107696, 'lng': 72.839676},
      {'name': 'Prithvi Theatre', 'lat': 19.106988, 'lng': 72.825341},
      {'name': 'Lallu Bhai Park', 'lat': 19.114578, 'lng': 72.844162},
      {'name': 'PVR Cinemas, Juhu', 'lat': 19.098769, 'lng': 72.825507},
    ],
    'Tourist Spots': [
      {'name': 'Juhu Beach', 'lat': 19.09867, 'lng': 72.825647},
      {'name': 'ISKCON Temple, Juhu', 'lat': 19.113659, 'lng': 72.826993},
      {'name': 'Versova Beach', 'lat': 19.125307, 'lng': 72.817072},
      {'name': 'Mumbai Selfie Point', 'lat': 19.104819, 'lng': 72.830083},
    ],
  };

  Map<String, dynamic>? selectedPlace;

  @override
  Widget build(BuildContext context) {
    final places = nearbyPlaces[selectedCategory]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Around"),
        backgroundColor: Colors.blue[700],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          Offset? popupOffset;

          if (selectedPlace != null) {
            final markerLatLng = LatLng(selectedPlace!['lat'], selectedPlace!['lng']);
            final dx = (markerLatLng.longitude - collegeLocation.longitude) * 10000;
            final dy = (markerLatLng.latitude - collegeLocation.latitude) * -10000;
            popupOffset = Offset(constraints.maxWidth / 2 + dx - 100, constraints.maxHeight / 2 + dy - 80);
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: collegeLocation,
                  initialZoom: 16.0,
                  onTap: (_, __) => setState(() => selectedPlace = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: collegeLocation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                      ...places.map(
                        (place) => Marker(
                          width: 60,
                          height: 60,
                          point: LatLng(place['lat'], place['lng']),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedPlace = place),
                            child: Column(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 35),
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    place['name'],
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (selectedPlace != null && popupOffset != null)
                Positioned(
                  left: popupOffset.dx - 100,
                  top: popupOffset.dy,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(selectedPlace!['name'], style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(selectedCategory, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 4, offset: const Offset(2, 2))],
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    underline: const SizedBox(),
                    items: nearbyPlaces.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedCategory = val;
                          selectedPlace = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
