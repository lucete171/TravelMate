import 'package:flutter/material.dart';

class TravelStyl5Page extends StatelessWidget {
  final List<Map<String, dynamic>> travelStyl5Options = [
    {'value': '1', 'label': '휴양 매우 선호', 'icon': Icons.spa},
    {'value': '2', 'label': '휴양 선호', 'icon': Icons.beach_access},
    {'value': '3', 'label': '휴양 약간 선호', 'icon': Icons.local_florist},
    {'value': '4', 'label': '중립', 'icon': Icons.compare_arrows},
    {'value': '5', 'label': '체험 약간 선호', 'icon': Icons.hiking},
    {'value': '6', 'label': '체험 선호', 'icon': Icons.directions_bike},
    {'value': '7', 'label': '체험 매우 선호', 'icon': Icons.directions_run},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('휴식 VS 체험 선택'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        color: Color(0xFFEDE7F6), // 배경색 연보라색으로 설정
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 열의 수를 2로 설정하여 더 큰 버튼 제공
            childAspectRatio: 1.0, // 버튼의 비율 (너비/높이)
            crossAxisSpacing: 12.0, // 열 사이의 간격
            mainAxisSpacing: 12.0, // 행 사이의 간격
          ),
          itemCount: travelStyl5Options.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'value': travelStyl5Options[index]['value'],
                  'text': travelStyl5Options[index]['label']
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
                    travelStyl5Options[index]['icon'],
                    color: Colors.deepPurpleAccent,
                    size: 36,
                  ),
                  SizedBox(height: 8),
                  Text(
                    travelStyl5Options[index]['label']!,
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
