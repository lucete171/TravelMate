import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SavedRoutesPage extends StatefulWidget {
  @override
  _SavedRoutesPageState createState() => _SavedRoutesPageState();
}

class _SavedRoutesPageState extends State<SavedRoutesPage> {
  late GoogleMapController _mapController;
  final LatLng _initialCenter = const LatLng(33.450701, 126.570667); // 초기 지도 위치 (제주도)
  List<String> _savedRoutes = ["Route 1", "Route 2", "Route 3", "Route 4"]; // 예시 루트 리스트

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _savedRoutes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_savedRoutes[index]),
                      onTap: () {
                        // 루트를 선택하면 루트의 디테일 페이지로 이동
                        // 여기서 특정 루트의 정보를 기반으로 맵을 업데이트하거나, 다른 페이지로 이동 가능
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
