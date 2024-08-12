import 'package:flutter/material.dart';

class TravelStyl5Page extends StatelessWidget {
  final List<Map<String, String>> travelStyl5Options = [
    {'value': '1', 'label': '휴양 매우 선호'},
    {'value': '2', 'label': '휴양 선호'},
    {'value': '3', 'label': '휴양 약간 선호'},
    {'value': '4', 'label': '중립'},
    {'value': '5', 'label': '체험 약간 선호'},
    {'value': '6', 'label': '체험 선호'},
    {'value': '7', 'label': '체험 매우 선호'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('휴식 VS 체험 선택')),
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
          itemCount: travelStyl5Options.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'value': travelStyl5Options[index]['value'], 'text': travelStyl5Options[index]['label']});
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
                travelStyl5Options[index]['label']!,
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
