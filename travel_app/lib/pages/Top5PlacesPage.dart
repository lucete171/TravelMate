import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/route_map_page.dart';

Future<String?> fetchImageUrl(String query) async {
  final apiKey = 'AIzaSyBEDOjx-flm23wa6tL5YFFWdNOLBqHzTNo'; // Google Cloud에서 생성한 API 키를 여기에 입력하세요.
  final searchEngineId = '95c78552f9185462d'; // Custom Search Engine ID를 여기에 입력하세요.

  final url =
      'https://www.googleapis.com/customsearch/v1?q=jeju $query&searchType=image&key=$apiKey&cx=$searchEngineId&num=1';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        final imageUrl = data['items'][0]['link'];
        return imageUrl;
      } else {
        print('No image found for query: $query');
        return null;
      }
    } else {
      print('Failed to load image, status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error occurred: $e');
    return null;
  }
}

class Top5PlacesPage extends StatefulWidget {
  final Map<String, List<Place>> top5Data;

  Top5PlacesPage({required this.top5Data});

  @override
  _Top5PlacesPageState createState() => _Top5PlacesPageState();
}

class _Top5PlacesPageState extends State<Top5PlacesPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    super.initState();
  }


  void _onRecommendRoutePressed() {
    // Map<String, List<Place>>를 List<List<Place>>로 변환
    List<List<Place>> placesByDay = widget.top5Data.values.toList();

    // RouteMapPage로 변환된 데이터 전달
    Get.to(RouteMapPage(placesByDay: placesByDay));

    print('동선 추천 받기 버튼이 눌렸습니다.');
  }


  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 5 Places for you'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            width: size.width,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                labelPadding: EdgeInsets.only(
                    left: size.width * 0.05, right: size.width * 0.05),
                controller: tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: CircleTabBarIndicator(
                  color: Colors.deepPurpleAccent,
                  radius: 4,
                ),
                tabs: const [
                  Tab(text: "식당"),
                  Tab(text: "카페"),
                  Tab(text: "여행지"),
                  Tab(text: "숙소"),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                Top5List(places: widget.top5Data['식당'] ?? []),
                Top5List(places: widget.top5Data['카페'] ?? []),
                Top5List(places: widget.top5Data['여행지'] ?? []),
                Top5List(places: widget.top5Data['숙소'] ?? []),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _onRecommendRoutePressed,
              child: Text(
                '동선 추천 받기',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Top5List extends StatelessWidget {
  final List<Place> places;

  const Top5List({required this.places});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return FutureBuilder<String?>(
          future: fetchImageUrl(place.name), // 이미지 URL 가져오기
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  width: double.infinity,
                  height: 400, // 원하는 높이로 설정
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.image, size: 50), // 기본 아이콘 사용
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '위치: ${place.address}\n예상 만족도: ${place.satisfaction.toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  width: double.infinity,
                  height: 400, // 원하는 높이로 설정
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '위치: ${place.address}\n예상 만족도: ${place.satisfaction.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}



class Place {
  final String name;
  final String address;
  final double satisfaction;
  final double latitude;
  final double longitude;

  Place({
    required this.name,
    required this.address,
    required this.satisfaction,
    required this.latitude,
    required this.longitude,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      address: json['address'],
      satisfaction: json['satisfaction'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class CircleTabBarIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabBarIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
    ..color = color
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset = offset +
        Offset(cfg.size!.width / 2, cfg.size!.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
