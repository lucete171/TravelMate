import 'package:flutter/material.dart';

class TravelMissionPriorityPage extends StatelessWidget {
  final List<Map<String, dynamic>> travelMissionPriorities = [
    {'title': '쇼핑', 'icon': Icons.shopping_bag},
    {'title': '테마파크/놀이시설', 'icon': Icons.park},
    {'title': '역사 유적지방문', 'icon': Icons.account_balance},
    {'title': '시티투어', 'icon': Icons.location_city},
    {'title': '야외스포츠,레포츠', 'icon': Icons.sports_soccer},
    {'title': '지역 문화예술/공연/전시', 'icon': Icons.theater_comedy},
    {'title': '유흥/오락', 'icon': Icons.local_bar},
    {'title': '캠핑', 'icon': Icons.terrain},
    {'title': '지역 축제/이벤트 참가', 'icon': Icons.festival},
    {'title': '온천/스파', 'icon': Icons.spa},
    {'title': '교육/체험 프로그램 참여', 'icon': Icons.school},
    {'title': '드라마 촬영지 방문', 'icon': Icons.movie},
    {'title': '종교/성지 순례', 'icon': Icons.church},
    {'title': 'Well-ness여행', 'icon': Icons.self_improvement},
    {'title': 'SNS인생샷 여행', 'icon': Icons.camera_alt},
    {'title': '호캉스여행', 'icon': Icons.hotel},
    {'title': '신규 여행지 발굴', 'icon': Icons.explore},
    {'title': '반려동물 동반 여행', 'icon': Icons.pets},
    {'title': '인플루언서 따라하기', 'icon': Icons.person},
    {'title': '친환경 여행', 'icon': Icons.eco},
    {'title': '등반 여행', 'icon': Icons.hiking},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 목적 선택'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        color: Color(0xFFEDE7F6), // 배경색 연보라색으로 설정
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 열의 수
            childAspectRatio: 0.95, // 버튼의 비율 (너비/높이)
            crossAxisSpacing: 12.0, // 열 사이의 간격
            mainAxisSpacing: 12.0, // 행 사이의 간격
          ),
          itemCount: travelMissionPriorities.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'value': travelMissionPriorities[index]['title'],
                  'text': travelMissionPriorities[index]['title']
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
                    travelMissionPriorities[index]['icon'],
                    color: Colors.deepPurpleAccent,
                    size: 40, // 아이콘 크기를 조금 더 키웠습니다
                  ),
                  SizedBox(height: 8),
                  Text(
                    travelMissionPriorities[index]['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontSize: 14,
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
