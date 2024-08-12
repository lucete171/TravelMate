import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController mapController;
  final LatLng _initialCenter = const LatLng(33.450701, 126.570667); // 초기 지도 위치 (제주도)
  Set<Marker> _markers = {};

  TextEditingController _searchController = TextEditingController();

  static const String _googleApiKey = 'AIzaSyBEDOjx-flm23wa6tL5YFFWdNOLBqHzTNo';

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<List<String>> _getPlaceSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&language=ko'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final suggestions = json['predictions'] as List;

      return suggestions.map((s) => s['description'] as String).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _searchPlace(String place) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$place&inputtype=textquery&fields=geometry&key=$_googleApiKey'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final location = json['candidates'][0]['geometry']['location'];
      final LatLng latLng = LatLng(location['lat'], location['lng']);

      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('searchedPlace'),
          position: latLng,
          infoWindow: InfoWindow(title: place),
        ));
      });

      mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14.0));
    } else {
      throw Exception('Failed to find place');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map with Place Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '장소 검색',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await _getPlaceSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.toString()),
                );
              },
              onSuggestionSelected: (suggestion) {
                _searchController.text = suggestion.toString();
                _searchPlace(suggestion.toString());
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialCenter,
                zoom: 11.0,
              ),
              mapType: MapType.normal, // 지도 타입 설정
              zoomGesturesEnabled: true, // 확대/축소 제스처 활성화
              rotateGesturesEnabled: true, // 지도 회전 제스처 활성화
              markers: _markers, // 마커 추가
            ),
          ),
        ],
      ),
    );
  }
}
