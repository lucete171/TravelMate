import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

void uploadData() async {
  // JSON 파일을 읽어옵니다.
  String jsonString = await rootBundle.loadString('assets/data/tc_codeb.json');
  List<dynamic> jsonResponse = json.decode(jsonString);

  // Firestore에 데이터를 업로드합니다.
  CollectionReference visitAreaCollection = FirebaseFirestore.instance.collection('tc_codeb');

  for (var visitArea in jsonResponse) {
    await visitAreaCollection.add(visitArea);
  }

  print('Data uploaded successfully!');
}
