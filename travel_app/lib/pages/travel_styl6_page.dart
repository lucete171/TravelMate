import 'package:flutter/material.dart';

class TravelStyl6Page extends StatelessWidget {
  final List<Map<String, dynamic>> travelStyl6Options = [
    {'value': '1', 'label': '잘 알려지지 않은 곳 매우 선호', 'icon': Icons.explore},
    {'value': '2', 'label': '잘 알려지지 않은 곳 선호', 'icon': Icons.nature_people},
    {'value': '3', 'label': '잘 알려지지 않은 곳 약간 선호', 'icon': Icons.park},
    {'value': '4', 'label': '중립', 'icon': Icons.compare_arrows},
    {'value': '5', 'label': '유명한 곳 약간 선호', 'icon': Icons.star_half},
    {'value': '6', 'label': '유명한 곳 선호', 'icon': Icons.star},
    {'value': '7', 'label': '유명한 곳 매우 선호', 'icon': Icons.star_rate},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('유명한 VS 특별한 선택'),
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
          itemCount: travelStyl6Options.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'value': travelStyl6Options[index]['value'],
                  'text': travelStyl6Options[index]['label']
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
                    travelStyl6Options[index]['icon'],
                    color: Colors.deepPurpleAccent,
                    size: 36,
                  ),
                  SizedBox(height: 8),
                  Text(
                    travelStyl6Options[index]['label']!,
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
