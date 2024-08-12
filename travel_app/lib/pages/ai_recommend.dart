import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'travel_mission_priority_page.dart';
import 'travel_motive_page.dart';
import 'travel_styl1_page.dart';
import 'travel_styl5_page.dart';
import 'travel_styl6_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'Top5PlacesPage.dart';

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  String? travelMissionPriority;
  String? travelMotive1;
  String? travelStyl1;
  String? travelStyl5;
  String? travelStyl6;

  String? travelMissionPriorityText;
  String? travelMotive1Text;
  String? travelStyl1Text;
  String? travelStyl5Text;
  String? travelStyl6Text;

  DateTime? departureDate;
  DateTime? returnDate;
  Duration? travelDuration;

  bool _isAnimating = false;

  final Map<String, String> travelStyl1Map = {
    '1': '자연 매우 선호',
    '2': '자연 선호',
    '3': '자연 약간 선호',
    '4': '중립',
    '5': '도시 약간 선호',
    '6': '도시 선호',
    '7': '도시 매우 선호',
  };

  final Map<String, String> travelStyl5Map = {
    '1': '휴양 매우 선호',
    '2': '휴양 선호',
    '3': '휴양 약간 선호',
    '4': '중립',
    '5': '체험 약간 선호',
    '6': '체험 선호',
    '7': '체험 매우 선호',
  };

  final Map<String, String> travelStyl6Map = {
    '1': '잘 알려지지 않은 곳 매우 선호',
    '2': '잘 알려지지 않은 곳 선호',
    '3': '잘 알려지지 않은 곳 약간 선호',
    '4': '중립',
    '5': '유명한 곳 약간 선호',
    '6': '유명한 곳 선호',
    '7': '유명한 곳 매우 선호',
  };

  Future<void> saveJsonToFile(Map<String, dynamic> jsonData) async {
    // 앱의 문서 디렉토리 경로를 가져옵니다.
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/travel_data.json';

    // 파일을 생성하고 JSON 데이터를 문자열로 변환하여 저장합니다.
    final file = File(path);
    final jsonString = jsonEncode(jsonData);
    await file.writeAsString(jsonString);

    print('JSON data saved to: $path');
  }

  Future<String> readJsonFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/travel_data.json';
      final file = File(path);

      if (await file.exists()) {
        final contents = await file.readAsString();
        return contents;
      } else {
        return 'File not found';
      }
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  List<Place> parsePlacesFromJson(Map<String, dynamic> jsonData, String category) {
    final List<dynamic> placesJson = jsonData[category];
    return placesJson.map((json) => Place.fromJson(json)).toList();
  }

  Future<void> sendData() async {
    final String url = 'https://ec62-34-31-67-62.ngrok-free.app/list_recommend'; // 서버 URL을 입력하세요.
    final Map<String, dynamic> data = {
      'TRAVEL_MISSION_PRIORITY': travelMissionPriority,
      'TRAVEL_STYL_1': travelStyl1,
      'TRAVEL_STYL_5': travelStyl5,
      'TRAVEL_STYL_6': travelStyl6,
      'TRAVEL_MOTIVE_1': travelMotive1,
      'DEPARTURE_DATE': departureDate?.toIso8601String(),
      'RETURN_DATE': returnDate?.toIso8601String(),
      'TRAVEL_DURATION': travelDuration?.inDays,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // JSON 디코딩
      final jsonResponse = jsonDecode(response.body);

      List<Place> restaurants = parsePlacesFromJson(jsonResponse, '식당');
      List<Place> cafes = parsePlacesFromJson(jsonResponse, '카페');
      List<Place> touristAttractions = parsePlacesFromJson(jsonResponse, '여행지');
      List<Place> accommodations = parsePlacesFromJson(jsonResponse, '호텔');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Top5PlacesPage(
            top5Data: {
              '식당': restaurants,
              '카페': cafes,
              '여행지': touristAttractions,
              '숙소': accommodations,
            },
          ),
        ),
      );
    } else {
      print('Failed to fetch data');
      print('Error response from server: ${response.body}');
    }
  }

  void _navigateAndSave(BuildContext context, Widget page, String featureName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    setState(() {
      switch (featureName) {
        case 'travelMissionPriority':
          travelMissionPriority = result['value'];
          travelMissionPriorityText = result['text'];
          break;
        case 'travelMotive1':
          travelMotive1 = result['value'];
          travelMotive1Text = result['text'];
          break;
        case 'travelStyl1':
          travelStyl1 = result['value'];
          travelStyl1Text = result['text'];
          break;
        case 'travelStyl5':
          travelStyl5 = result['value'];
          travelStyl5Text = result['text'];
          break;
        case 'travelStyl6':
          travelStyl6 = result['value'];
          travelStyl6Text = result['text'];
          break;
      }
    });
  }

  void _playAnimation() {
    setState(() {
      _isAnimating = true;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? departureDate ?? DateTime.now() : returnDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isDeparture ? departureDate : returnDate))
      setState(() {
        if (isDeparture) {
          departureDate = picked;
          if (returnDate != null && picked.isAfter(returnDate!)) {
            returnDate = null;
            travelDuration = null;
          }
        } else {
          returnDate = picked;
          if (departureDate != null) {
            travelDuration = returnDate!.difference(departureDate!);
          }
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 추천 받기'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      backgroundColor: Color(0xFFEDE7F6),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0), // 패딩을 줄여서 공간 확보
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildElevatedButton(context, '여행 목적 선택', travelMissionPriorityText, () {
                  _navigateAndSave(context, TravelMissionPriorityPage(), 'travelMissionPriority');
                }, travelMissionPriority != null),
                if (travelMissionPriority != null)
                  _buildElevatedButton(context, '여행 동기 선택', travelMotive1Text, () {
                    _navigateAndSave(context, TravelMotivePage(), 'travelMotive1');
                  }, travelMotive1 != null),
                if (travelMotive1 != null)
                  _buildElevatedButton(context, '자연 VS 도시 선택', travelStyl1Text, () {
                    _navigateAndSave(context, TravelStyl1Page(), 'travelStyl1');
                  }, travelStyl1 != null),
                if (travelStyl1 != null)
                  _buildElevatedButton(context, '휴식 VS 체험 선택', travelStyl5Text, () {
                    _navigateAndSave(context, TravelStyl5Page(), 'travelStyl5');
                  }, travelStyl5 != null),
                if (travelStyl5 != null)
                  _buildElevatedButton(context, '유명한 VS 특별한 선택', travelStyl6Text, () {
                    _navigateAndSave(context, TravelStyl6Page(), 'travelStyl6');
                  }, travelStyl6 != null),
                if (travelStyl6 != null) ...[
                  _buildDateButton(context, '출발 일시 선택', departureDate, () => _selectDate(context, true)),
                  _buildDateButton(context, '도착 일시 선택', returnDate, () => _selectDate(context, false)),
                  if (departureDate != null && returnDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          sendData();
                          _playAnimation();
                        },
                        child: Text(
                          '추천받기',
                          style: TextStyle(color: Colors.white), // 글자 색 흰색으로 설정
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                ],
                if (_isAnimating)
                  Container(
                    width: size.width * 0.6, // 애니메이션 크기 조정
                    height: size.width * 0.6,
                    child: Lottie.asset('assets/animation/ai_robot.json'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(BuildContext context, String defaultText, String? selectedText, VoidCallback onPressed, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0), // 패딩을 줄여서 공간 확보
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            selectedText ?? defaultText,
            style: TextStyle(fontSize: 16), // 글자 크기 줄임
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.deepPurpleAccent : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.deepPurpleAccent,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // 버튼 크기 줄임
            textStyle: TextStyle(fontSize: 16),
            side: BorderSide(color: Colors.deepPurpleAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(BuildContext context, String text, DateTime? date, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0), // 패딩을 줄여서 공간 확보
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            date != null ? DateFormat('yyyy-MM-dd').format(date) : text,
            style: TextStyle(fontSize: 16), // 글자 크기 줄임
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: date != null ? Colors.deepPurpleAccent : Colors.white,
            foregroundColor: date != null ? Colors.white : Colors.deepPurpleAccent,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // 버튼 크기 줄임
            textStyle: TextStyle(fontSize: 16),
            side: BorderSide(color: Colors.deepPurpleAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
