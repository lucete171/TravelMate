import 'package:flutter/material.dart';

class TravelMotivePage extends StatelessWidget {
  final List<String> travelMotiveOptions = [
    '일상적인 환경',
    '쉴 수 있는 기회',
    '여행 동반자와 친밀',
    '진정한 자아 찾기',
    'SNS 사진 등록',
    '운동, 건강증진',
    '새로운 경험 추구',
    '역사탐방,문화적 경험',
    '특별한 목적',
    '기타'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('여행 동기 선택')),
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
          itemCount: travelMotiveOptions.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'value': travelMotiveOptions[index], 'text': travelMotiveOptions[index]});
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
                travelMotiveOptions[index],
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
