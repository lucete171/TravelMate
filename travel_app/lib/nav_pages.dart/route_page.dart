import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../pages/route_map_page.dart';  // TimePlace 클래스가 포함된 파일

class SavedRoutesPage extends StatefulWidget {
  @override
  _SavedRoutesPageState createState() => _SavedRoutesPageState();
}

class _SavedRoutesPageState extends State<SavedRoutesPage> {
  late GoogleMapController _mapController;
  final LatLng _initialCenter = const LatLng(33.450701, 126.570667); // 초기 지도 위치 (제주도)
  List<String> _savedRoutes = [];
  List<List<TimePlace>> _selectedPlacesByDay = [];
  int _selectedDay = 0;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // PageController 추가
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadSavedRoutes(); // 저장된 루트 불러오기
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _loadSavedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedRoutes = prefs.getStringList('scheduleNames') ?? [];
    setState(() {
      _savedRoutes = savedRoutes;
    });
  }

  void _showRouteOnMap(String scheduleName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? routeData = prefs.getString(scheduleName);

    if (routeData != null) {
      final List<dynamic> routeJson = jsonDecode(routeData);
      final List<List<TimePlace>> placesByDay = routeJson.map((dayPlaces) {
        return (dayPlaces as List).map((place) => TimePlace.fromJson(place)).toList();
      }).toList();

      setState(() {
        _selectedPlacesByDay = placesByDay;
        _selectedDay = 0; // 첫 번째 날로 초기화
        _setMarkersAndPolylines(); // 지도에 마커와 폴리라인 표시
      });

      if (placesByDay.isNotEmpty) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(_boundsFromLatLngList(placesByDay), 50),
        );
      }
    } else {
      print('No route data found for schedule: $scheduleName');
    }
  }

  Future<void> _deleteRoute(String scheduleName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedRoutes = prefs.getStringList('scheduleNames') ?? [];

    if (savedRoutes.contains(scheduleName)) {
      savedRoutes.remove(scheduleName);
      await prefs.setStringList('scheduleNames', savedRoutes);
      await prefs.remove(scheduleName);

      setState(() {
        _savedRoutes = savedRoutes;
      });
    }
  }

  void _confirmDeleteRoute(String scheduleName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('일정 삭제'),
          content: Text('정말 일정을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _deleteRoute(scheduleName); // 일정 삭제 수행
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _setMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();

    List<LatLng> latLngList = [];

    for (int dayIndex = 0; dayIndex < _selectedPlacesByDay.length; dayIndex++) {
      final places = _selectedPlacesByDay[dayIndex];
      for (var place in places) {
        LatLng position = LatLng(place.latitude, place.longitude);
        latLngList.add(position);

        _markers.add(Marker(
          markerId: MarkerId('${place.name}_day$dayIndex'),
          position: position,
          infoWindow: InfoWindow(title: place.name, snippet: place.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(dayIndex)),
        ));
      }

      _polylines.add(Polyline(
        polylineId: PolylineId('route_day$dayIndex'),
        points: latLngList,
        color: _getPolylineColor(dayIndex),
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));

      latLngList.clear();
    }
  }

  void _highlightPlaceOnMap(LatLng position) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(position, 15.0),
    );
  }

  LatLngBounds _boundsFromLatLngList(List<List<TimePlace>> placesByDay) {
    double x0 = placesByDay[0][0].latitude, x1 = placesByDay[0][0].latitude;
    double y0 = placesByDay[0][0].longitude, y1 = placesByDay[0][0].longitude;

    for (var places in placesByDay) {
      for (var place in places) {
        if (place.latitude > x1) x1 = place.latitude;
        if (place.latitude < x0) x0 = place.latitude;
        if (place.longitude > y1) y1 = place.longitude;
        if (place.longitude < y0) y0 = place.longitude;
      }
    }

    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }

  double _getMarkerColor(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return BitmapDescriptor.hueRed;
      case 1:
        return BitmapDescriptor.hueBlue;
      case 2:
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueYellow;
    }
  }

  Color _getPolylineColor(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Routes'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialCenter,
              zoom: 11.0,
            ),
            mapType: MapType.normal, // 지도 타입 설정
            markers: _markers, // 지도에 표시할 마커 설정
            polylines: _polylines, // 지도에 표시할 폴리라인 설정
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3, // 초기 비율
            minChildSize: 0.1, // 최소 비율
            maxChildSize: 0.8, // 최대 비율
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, -2), // 그림자 위치 조정
                    ),
                  ],
                ),
                child: _selectedPlacesByDay.isEmpty
                    ? ListView.builder(
                  controller: scrollController,
                  itemCount: _savedRoutes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(_savedRoutes[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteRoute(_savedRoutes[index]); // 삭제 확인 다이얼로그 호출
                          },
                        ),
                        onTap: () {
                          _showRouteOnMap(_savedRoutes[index]);
                        },
                      ),
                    );
                  },
                )
                    : Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController, // PageController 사용
                      itemCount: _selectedPlacesByDay.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedDay = index;
                          _setMarkersAndPolylines();
                        });
                      },
                      itemBuilder: (context, dayIndex) {
                        final places = _selectedPlacesByDay[dayIndex];
                        return Container(
                          padding: EdgeInsets.all(8.0),
                          color: Colors.white,
                          child: ListView.separated(
                            itemCount: places.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey),
                            itemBuilder: (context, index) {
                              final place = places[index];
                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(8.0),
                                  title: Text(place.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(place.address),
                                      SizedBox(height: 4),
                                      Text('예상 만족도: ${place.satisfaction.toStringAsFixed(2)}'),
                                      SizedBox(height: 4),
                                      Text('시간: ${place.start} - ${place.end}'),
                                    ],
                                  ),
                                  onTap: () {
                                    _highlightPlaceOnMap(LatLng(place.latitude, place.longitude));
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _selectedPlacesByDay = [];
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
