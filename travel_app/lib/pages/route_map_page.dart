import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 파싱을 위해 필요
import 'Top5PlacesPage.dart';
import 'package:http/http.dart' as http;

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({Key? key}) : super(key: key);

  @override
  _RouteMapPageState createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<List<TimePlace>> placesByDay = [];
  TimePlace? _selectedPlace;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _fetchDataFromServer(); // 서버에서 데이터를 받아옴
  }

  Future<void> _fetchDataFromServer() async {
    final url = Uri.parse('https://faf0-35-240-197-108.ngrok-free.app/course_recommend'); // 서버 URL을 지정
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body); // JSON 데이터를 리스트로 파싱
        print('서버 응답: $dataList'); // 데이터를 콘솔에 출력

        // 데이터를 파싱하여 placesByDay 리스트에 저장
        setState(() {
          placesByDay = _parsePlacesByDay(dataList);
          _setMarkersAndPolylines(); // 데이터가 로드된 후에 마커와 폴리라인 설정
        });
      } else {
        print('데이터 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('데이터 패치 오류: $e');
    }
  }

  List<List<TimePlace>> _parsePlacesByDay(List<dynamic> dataList) {
    List<List<TimePlace>> parsedPlaces = [];

    for (var dayData in dataList) {
      dayData.forEach((day, places) {
        List<TimePlace> dayPlaces = [];
        for (var placeData in places) {
          dayPlaces.add(TimePlace.fromJson(placeData));
        }
        parsedPlaces.add(dayPlaces);
      });
    }

    return parsedPlaces;
  }

  Future<void> _saveRoute(String scheduleName) async {
    final prefs = await SharedPreferences.getInstance();

    // 일정 이름 리스트를 가져옵니다.
    List<String> scheduleNames = prefs.getStringList('scheduleNames') ?? [];

    // 새로운 일정 이름을 리스트에 추가합니다.
    if (!scheduleNames.contains(scheduleName)) {
      scheduleNames.add(scheduleName);
      await prefs.setStringList('scheduleNames', scheduleNames);
    }

    // 일정 데이터를 저장합니다.
    final String routeData = jsonEncode(placesByDay.map((dayPlaces) {
      return dayPlaces.map((place) => place.toJson()).toList();
    }).toList());

    await prefs.setString(scheduleName, routeData);
    print('Route saved successfully under name: $scheduleName');

    // 저장 완료 메시지를 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('일정이 성공적으로 저장되었습니다.')),
    );
  }

  Future<void> _showSaveDialog() async {
    TextEditingController _textFieldController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('일정 이름을 입력하세요'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "일정 이름"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('저장'),
              onPressed: () {
                String scheduleName = _textFieldController.text;
                if (scheduleName.isNotEmpty) {
                  _saveRoute(scheduleName); // 입력된 이름으로 루트 저장
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _setMarkersAndPolylines() {
    List<LatLng> latLngList = [];

    for (int dayIndex = 0; dayIndex < placesByDay.length; dayIndex++) {
      final places = placesByDay[dayIndex];
      for (var place in places) {
        LatLng position = LatLng(place.latitude, place.longitude);
        latLngList.add(position);

        _markers.add(Marker(
          markerId: MarkerId('${place.name}_day$dayIndex'),
          position: position,
          infoWindow: InfoWindow(title: place.name, snippet: place.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(dayIndex)),
          onTap: () {
            _onMarkerTapped(place);
          },
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

  void _onMarkerTapped(TimePlace place) {
    setState(() {
      _selectedPlace = place;
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(place.latitude, place.longitude)),
    );
  }

  void _onSaveRoutePressed() {
    _showSaveDialog(); // 일정 이름 입력 다이얼로그를 띄움
  }

  void _onDaySelected(int dayIndex) {
    setState(() {
      _selectedDay = dayIndex;
      _selectedPlace = null;
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(_boundsFromLatLngList(dayIndex), 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Map'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _onSaveRoutePressed,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                if (placesByDay.isNotEmpty) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_selectedDay), 50),
                  );
                }
              },
              markers: _markers,
              polylines: _polylines,
              initialCameraPosition: CameraPosition(
                target: LatLng(33.4500, 126.5700),
                zoom: 10,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: placesByDay.isNotEmpty
                ? PageView.builder(
              itemCount: placesByDay.length,
              onPageChanged: (index) {
                _onDaySelected(index);
              },
              itemBuilder: (context, dayIndex) {
                final places = placesByDay[dayIndex];
                return Container(
                  padding: EdgeInsets.all(8.0),
                  color: _selectedDay == dayIndex ? Colors.blue[100] : Colors.white,
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
                            _onMarkerTapped(place);
                          },
                          tileColor: _selectedPlace == place ? Colors.blue[100] : null,
                        ),
                      );
                    },
                  ),
                );
              },
            )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  LatLngBounds _boundsFromLatLngList(int dayIndex) {
    double x0 = placesByDay[dayIndex][0].latitude, x1 = placesByDay[dayIndex][0].latitude;
    double y0 = placesByDay[dayIndex][0].longitude, y1 = placesByDay[dayIndex][0].longitude;

    for (var place in placesByDay[dayIndex]) {
      if (place.latitude > x1) x1 = place.latitude;
      if (place.latitude < x0) x0 = place.latitude;
      if (place.longitude > y1) y1 = place.longitude;
      if (place.longitude < y0) y0 = place.longitude;
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
}

class TimePlace extends Place {
  final String? start;
  final String? end;

  TimePlace({
    required String name,
    required String address,
    required double satisfaction,
    required double latitude,
    required double longitude,
    this.start,
    this.end,
  }) : super(
    name: name,
    address: address,
    satisfaction: satisfaction,
    latitude: latitude,
    longitude: longitude,
  );

  factory TimePlace.fromJson(Map<String, dynamic> json) {
    return TimePlace(
      name: json['name'],
      address: json['address'],
      satisfaction: json['satisfaction'].toDouble(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      start: json['start'],
      end: json['end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'satisfaction': satisfaction,
      'latitude': latitude,
      'longitude': longitude,
      'start': start,
      'end': end,
    };
  }
}
