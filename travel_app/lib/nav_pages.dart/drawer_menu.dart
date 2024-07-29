import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/setting/setting_page.dart';
import '../pages/calender.dart';
import '../data/upload.dart';
import '../pages/ai_recommend.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 220, 200, 220),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('My'),
            onTap: () {
              //my page
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('여행 계획 세우기 (AI)'),
            onTap: () {
              Get.to(InputForm());
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('캘린더'),
            onTap: () {
              Get.to(TravelCalendar());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Get.to(const SettingPage());
            },
          ),
        ],
      ),
    );
  }
}
