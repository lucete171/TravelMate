import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  final List<Map<String, String>> travelStyl1Options = [
    {'value': '1', 'label': '자연 매우 선호'},
    {'value': '2', 'label': '자연 선호'},
    {'value': '3', 'label': '자연 약간 선호'},
    {'value': '4', 'label': '중립'},
    {'value': '5', 'label': '도시 약간 선호'},
    {'value': '6', 'label': '도시 선호'},
    {'value': '7', 'label': '도시 매우 선호'},
  ];

  final List<Map<String, String>> travelStyl5Options = [
    {'value': '1', 'label': '휴양 매우 선호'},
    {'value': '2', 'label': '휴양 선호'},
    {'value': '3', 'label': '휴양 약간 선호'},
    {'value': '4', 'label': '중립'},
    {'value': '5', 'label': '체험 약간 선호'},
    {'value': '6', 'label': '체험 선호'},
    {'value': '7', 'label': '체험 매우 선호'},
  ];

  final List<Map<String, String>> travelStyl6Options = [
    {'value': '1', 'label': '잘 알려지지 않은 곳 매우 선호'},
    {'value': '2', 'label': '잘 알려지지 않은 곳 선호'},
    {'value': '3', 'label': '잘 알려지지 않은 곳 약간 선호'},
    {'value': '4', 'label': '중립'},
    {'value': '5', 'label': '유명한 곳 약간 선호'},
    {'value': '6', 'label': '유명한 곳 선호'},
    {'value': '7', 'label': '유명한 곳 매우 선호'},
  ];

  Future<void> sendData() async {
    final String url = 'https://d95c-35-197-154-244.ngrok-free.app/receive_data'; // 서버 URL을 입력하세요.
    final Map<String, dynamic> data = {
      'TRAVEL_MISSION_PRIORITY': travelMissionPriority,
      'TRAVEL_STYL_1': travelStyl1,
      'TRAVEL_STYL_5': travelStyl5,
      'TRAVEL_STYL_6': travelStyl6,
      'TRAVEL_MOTIVE_1': travelMotive1,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 추천 받기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '여행 목적'),
                value: travelMissionPriority,
                onChanged: (String? newValue) {
                  setState(() {
                    travelMissionPriority = newValue;
                  });
                },
                items: travelMissionPriorities.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '여행 동기'),
                value: travelMotive1,
                onChanged: (String? newValue) {
                  setState(() {
                    travelMotive1 = newValue;
                  });
                },
                items: travelMotiveOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '자연 VS 도시'),
                value: travelStyl1,
                onChanged: (String? newValue) {
                  setState(() {
                    travelStyl1 = newValue;
                  });
                },
                items: travelStyl1Options.map<DropdownMenuItem<String>>((Map<String, String> option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '휴식 VS 체험'),
                value: travelStyl5,
                onChanged: (String? newValue) {
                  setState(() {
                    travelStyl5 = newValue;
                  });
                },
                items: travelStyl5Options.map<DropdownMenuItem<String>>((Map<String, String> option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '유명한 VS 특별한'),
                value: travelStyl6,
                onChanged: (String? newValue) {
                  setState(() {
                    travelStyl6 = newValue;
                  });
                },
                items: travelStyl6Options.map<DropdownMenuItem<String>>((Map<String, String> option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendData,
                child: Text('추천받기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
