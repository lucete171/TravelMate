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

  List<DateTime?> startTimes = [];
  List<DateTime?> endTimes = [];

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

  final Map<String, IconData> iconMap = {
    '여행 목적': Icons.flag,
    '여행 동기': Icons.lightbulb_outline,
    '자연 VS 도시': Icons.landscape,
    '휴식 VS 체험': Icons.spa,
    '유명한 VS 특별한': Icons.star_outline,
  };

  Future<void> saveJsonToFile(Map<String, dynamic> jsonData) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/travel_data.json';

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
    _showLoadingDialog();
    final String url = 'https://your-server-url.com/list_recommend'; // 서버 URL을 입력하세요.
    final Map<String, dynamic> data = {
      'TRAVEL_MISSION_PRIORITY': travelMissionPriority,
      'TRAVEL_STYL_1': travelStyl1,
      'TRAVEL_STYL_5': travelStyl5,
      'TRAVEL_STYL_6': travelStyl6,
      'TRAVEL_MOTIVE_1': travelMotive1,
      'start_time': startTimes.map((date) => date?.toIso8601String()).toList(),
      'end_time': endTimes.map((date) => date?.toIso8601String()).toList(),
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Dialog 밖을 눌러도 닫히지 않게 설정
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 100,
            height: 100,
            child: Lottie.asset('assets/animation/ai_robot.json'),
          ),
        );
      },
    );
  }

  void _playAnimation() {
    setState(() {
      _isAnimating = true;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now().add(Duration(days: 2))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDateRange != null) {
      setState(() {
        startTimes.clear();
        endTimes.clear();

        final Duration range = pickedDateRange.end.difference(pickedDateRange.start);
        for (int i = 0; i <= range.inDays; i++) {
          final DateTime currentDate = pickedDateRange.start.add(Duration(days: i));
          startTimes.add(DateTime(currentDate.year, currentDate.month, currentDate.day, 9, 0)); // 기본 시작 시간 09:00
          endTimes.add(DateTime(currentDate.year, currentDate.month, currentDate.day, 18, 0)); // 기본 끝 시간 18:00
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, int index, bool isStartTime) async {
    final DateTime? selectedDate = startTimes[index];
    if (selectedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: isStartTime
            ? TimeOfDay.fromDateTime(selectedDate)
            : TimeOfDay.fromDateTime(endTimes[index]!),
      );

      if (pickedTime != null) {
        setState(() {
          final DateTime updatedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStartTime) {
            startTimes[index] = updatedDateTime;
          } else {
            endTimes[index] = updatedDateTime;
          }
        });
      }
    }
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 버튼들을 카드로 감싸고 2열로 배치
                _buildCardRow([
                  _buildFeatureCard(context, '여행 목적', travelMissionPriorityText, iconMap['여행 목적']!, () {
                    _navigateAndSave(context, TravelMissionPriorityPage(), 'travelMissionPriority');
                  }, travelMissionPriority != null),
                  if (travelMissionPriority != null)
                    _buildFeatureCard(context, '여행 동기', travelMotive1Text, iconMap['여행 동기']!, () {
                      _navigateAndSave(context, TravelMotivePage(), 'travelMotive1');
                    }, travelMotive1 != null),
                ]),
                if (travelMotive1 != null)
                  _buildCardRow([
                    _buildFeatureCard(context, '자연 VS 도시', travelStyl1Text, iconMap['자연 VS 도시']!, () {
                      _navigateAndSave(context, TravelStyl1Page(), 'travelStyl1');
                    }, travelStyl1 != null),
                    _buildFeatureCard(context, '휴식 VS 체험', travelStyl5Text, iconMap['휴식 VS 체험']!, () {
                      _navigateAndSave(context, TravelStyl5Page(), 'travelStyl5');
                    }, travelStyl5 != null),
                  ]),
                if (travelStyl5 != null)
                  _buildCardRow([
                    _buildFeatureCard(context, '유명한 VS 특별한', travelStyl6Text, iconMap['유명한 VS 특별한']!, () {
                      _navigateAndSave(context, TravelStyl6Page(), 'travelStyl6');
                    }, travelStyl6 != null),
                    _buildFeatureCard(context, '여행 날짜 범위 선택', null, Icons.date_range, () {
                      _selectDateRange(context);
                    }, true),
                  ]),
                // 날짜와 시간 선택 UI
                if (startTimes.isNotEmpty)
                  for (int i = 0; i < startTimes.length; i++)
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day ${i + 1} (${DateFormat('yyyy-MM-dd').format(startTimes[i]!)}):',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeButton(
                                      context, '시작 시간 선택', startTimes[i], Icons.access_time, () => _selectTime(context, i, true)),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _buildTimeButton(
                                      context, '끝 시간 선택', endTimes[i], Icons.access_time, () => _selectTime(context, i, false)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                if (startTimes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        sendData();
                      },
                      child: Text(
                        '추천받기',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                if (_isAnimating)
                  Container(
                    width: size.width * 0.6,
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

  Widget _buildCardRow(List<Widget> cards) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: cards,
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String? selectedText, IconData icon, VoidCallback onPressed, bool isSelected) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.deepPurpleAccent, size: 30),
              SizedBox(height: 10),
              Text(
                selectedText ?? title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.deepPurpleAccent,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurpleAccent : Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Colors.deepPurpleAccent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context, String text, DateTime? time, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: time != null ? Colors.white : Colors.deepPurpleAccent),
          SizedBox(width: 5),
          Text(
            time != null ? DateFormat('HH:mm').format(time) : text,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: time != null ? Colors.deepPurpleAccent : Colors.white,
        foregroundColor: time != null ? Colors.white : Colors.deepPurpleAccent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: TextStyle(fontSize: 16),
        side: BorderSide(color: Colors.deepPurpleAccent, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
