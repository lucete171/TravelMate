import 'package:flutter/material.dart';

class TravelStyl6Page extends StatelessWidget {
  final List<Map<String, String>> travelStyl6Options = [
    {'value': '1', 'label': '잘 알려지지 않은 곳 매우 선호'},
    {'value': '2', 'label': '잘 알려지지 않은 곳 선호'},
    {'value': '3', 'label': '잘 알려지지 않은 곳 약간 선호'},
    {'value': '4', 'label': '중립'},
    {'value': '5', 'label': '유명한 곳 약간 선호'},
    {'value': '6', 'label': '유명한 곳 선호'},
    {'value': '7', 'label': '유명한 곳 매우 선호'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('유명한 VS 특별한 선택')),
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
          itemCount: travelStyl6Options.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'value': travelStyl6Options[index]['value'], 'text': travelStyl6Options[index]['label']});
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
                travelStyl6Options[index]['label']!,
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
