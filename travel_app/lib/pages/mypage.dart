import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_app/view/auth/auth_page.dart';
import '../data/constant.dart';
import '../data/user.dart';
import '../widget/reuseable_text.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  Future<void> _logout() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? type = prefs.getString('type');

    if (type == SignType.Google.name) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    }

    await auth.signOut();
    await prefs.clear();

    Get.offAll(AuthPage());
  }

  @override
  Widget build(BuildContext context) {
    final CraftyUser user = Get.find<CraftyUser>();
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: AppText(
                  text: 'My Page',
                  size: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Sign-in Method'),
                  subtitle: Text(user.type),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('UID'),
                  subtitle: Text(user.uid),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              const Divider(),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // 설정 페이지로 이동하는 기능을 추가할 수 있습니다.
                  },
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 900),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Login History'),
                  onTap: () {
                    // 로그인 기록 페이지로 이동하는 기능을 추가할 수 있습니다.
                  },
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {
                    // 도움말 및 지원 페이지로 이동하는 기능을 추가할 수 있습니다.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'My Page',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
