import 'package:flutter/material.dart';

class TravelMotivePage extends StatelessWidget {
  final List<Map<String, dynamic>> travelMotiveOptions = [
    {'text': '일상적인 환경', 'icon': Icons.home},
    {'text': '쉴 수 있는 기회', 'icon': Icons.spa},
    {'text': '여행 동반자와 친밀', 'icon': Icons.favorite},
    {'text': '진정한 자아 찾기', 'icon': Icons.self_improvement},
    {'text': 'SNS 사진 등록', 'icon': Icons.camera_alt},
    {'text': '운동, 건강증진', 'icon': Icons.fitness_center},
    {'text': '새로운 경험 추구', 'icon': Icons.explore},
    {'text': '역사탐방,문화적 경험', 'icon': Icons.history_edu},
    {'text': '특별한 목적', 'icon': Icons.star},
    {'text': '기타', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 동기 선택'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        color: Color(0xFFEDE7F6), // 배경색 연보라색으로 설정
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 열의 수
            childAspectRatio: 1.0, // 버튼의 비율 (너비/높이)
            crossAxisSpacing: 12.0, // 열 사이의 간격
            mainAxisSpacing: 12.0, // 행 사이의 간격
          ),
          itemCount: travelMotiveOptions.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'value': travelMotiveOptions[index]['text'],
                  'text': travelMotiveOptions[index]['text'],
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
                elevation: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    travelMotiveOptions[index]['icon'],
                    color: Colors.deepPurpleAccent,
                    size: 36,
                  ),
                  SizedBox(height: 8),
                  Text(
                    travelMotiveOptions[index]['text'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
