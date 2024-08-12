import 'package:flutter/material.dart';

class TravelMissionPriorityPage extends StatelessWidget {
  final List<String> travelMissionPriorities = [
    '쇼핑',
    '테마파크/놀이시설',
    '역사 유적지방문',
    '시티투어',
    '야외스포츠,레포츠',
    '지역 문화예술/공연/전시',
    '유흥/오락',
    '캠핑',
    '지역 축제/이벤트 참가',
    '온천/스파',
    '교육/체험 프로그램 참여',
    '드라마 촬영지 방문',
    '종교/성지 순례',
    'Well-ness여행',
    'SNS인생샷 여행',
    '호캉스여행',
    '신규 여행지 발굴',
    '반려동물 동반 여행',
    '인플루언서 따라하기',
    '친환경 여행',
    '등반 여행'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('여행 목적 선택')),
      body: Container(
        color: Color(0xFFEDE7F6), // 배경색 연보라색으로 설정
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 열의 수
            childAspectRatio: 1.0, // 버튼의 비율 (너비/높이)
            crossAxisSpacing: 8.0, // 열 사이의 간격
            mainAxisSpacing: 8.0, // 행 사이의 간격
          ),
          itemCount: travelMissionPriorities.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'value': travelMissionPriorities[index], 'text': travelMissionPriorities[index]});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                travelMissionPriorities[index],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            );
          },
        ),
      ),
    );
  }
}
