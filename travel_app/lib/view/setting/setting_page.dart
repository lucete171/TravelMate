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
        title: const Text('설정'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          SwitchListTile(
              title:const Text('알림 설정'),
              value: _notification,
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
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut().then((value) async {
                  final SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await preferences.remove("id");
                  await preferences.remove("pw");
                  Get.off(IntroPage());
                });
              },
              child: Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 210, 210, 240),
              ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {Get.to(LicensePage());},
            child: Text('라이센스'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 210, 210, 240),
            ),
          ),
        ],
      ));
  }

  void initProfile() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        _notification = preferences.getBool("hobbyNoti")!;
      });
    }
  }
}


















