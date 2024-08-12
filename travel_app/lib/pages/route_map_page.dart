import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Top5PlacesPage.dart';

class RouteMapPage extends StatefulWidget {
  final List<List<Place>> placesByDay;

  const RouteMapPage({required this.placesByDay});

  @override
  _RouteMapPageState createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Place? _selectedPlace;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _setMarkersAndPolylines();
  }

  void _setMarkersAndPolylines() {
    List<LatLng> latLngList = [];

    for (int dayIndex = 0; dayIndex < widget.placesByDay.length; dayIndex++) {
      final places = widget.placesByDay[dayIndex];
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

  void _onMarkerTapped(Place place) {
    setState(() {
      _selectedPlace = place;
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(place.latitude, place.longitude)),
    );
  }

  void _onSaveRoutePressed() {
    // 여기에 루트 저장 로직을 추가합니다.
    print('루트 저장하기 버튼이 눌렸습니다.');
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
                _mapController.animateCamera(
                  CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_selectedDay), 50),
                );
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
            child: PageView.builder(
              itemCount: widget.placesByDay.length,
              onPageChanged: (index) {
                _onDaySelected(index);
              },
              itemBuilder: (context, dayIndex) {
                final places = widget.placesByDay[dayIndex];
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
                              Text('Satisfaction: ${place.satisfaction}'),
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
            ),
          ),
        ],
      ),
    );
  }

  LatLngBounds _boundsFromLatLngList(int dayIndex) {
    double x0 = widget.placesByDay[dayIndex][0].latitude, x1 = widget.placesByDay[dayIndex][0].latitude;
    double y0 = widget.placesByDay[dayIndex][0].longitude, y1 = widget.placesByDay[dayIndex][0].longitude;

    for (var place in widget.placesByDay[dayIndex]) {
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
  @override
  final int? travelTime;

  TimePlace({
    required super.name,
    required super.address,
    required super.satisfaction,
    required super.latitude,
    required super.longitude,
    required this.travelTime,
  });
}
