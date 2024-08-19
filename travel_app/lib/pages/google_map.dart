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
        title: Text('Google Map'),
        backgroundColor: Colors.deepPurpleAccent, // 앱바 색상 변경
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // 패딩 추가
            child: Material(
              elevation: 5.0, // 그림자 효과 추가
              borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '장소 검색',
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurpleAccent), // 검색 아이콘 추가
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white, // 텍스트 필드 배경색 변경
                  ),
                  style: TextStyle(fontSize: 16.0), // 텍스트 스타일 변경
                ),
                suggestionsCallback: (pattern) async {
                  return await _getPlaceSuggestions(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: Icon(Icons.place, color: Colors.deepPurpleAccent), // 아이콘 추가
                    title: Text(suggestion.toString()),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  _searchController.text = suggestion.toString();
                  _searchPlace(suggestion.toString());
                },
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)), // 상단 모서리 둥글게
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
          ),
        ],
      ),
    );
  }
}
