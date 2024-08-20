import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../intro/intro_page.dart';
import 'licens_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingPage();
  }
}

class _SettingPage extends State<SettingPage> {
  bool _notification = false;
  CraftyUser user = Get.find();

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: SwitchListTile(
                title: Text(
                  '알림 설정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                value: _notification,
                activeColor: Colors.deepPurpleAccent,
                secondary: Icon(Icons.notifications_active, color: Colors.deepPurpleAccent),
                onChanged: (value) async {
                  setState(() {
                    _notification = value;
                  });
                  await FirebaseFirestore.instance
                      .collection('craftyusers')
                      .doc(user.email)
                      .update({'noti': value});
                  final SharedPreferences preferences =
                  await SharedPreferences.getInstance();
                  await preferences.setBool('noto', value);
                },
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.redAccent),
                title: Text(
                  '로그아웃',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut().then((value) async {
                    final SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                    await preferences.remove("id");
                    await preferences.remove("pw");
                    Get.off(IntroPage());
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blueAccent),
                title: Text(
                  '라이센스',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Get.to(LicensePage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initProfile() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notification = preferences.getBool("hobbyNoti")!;
      });
    }
  }
}
