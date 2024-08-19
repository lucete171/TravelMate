import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/constant.dart';
import '../data/user.dart';
import '../view/auth/auth_page.dart';
import '../widget/reuseable_text.dart';
import 'travel_log_detail.dart';
import '../view/setting/setting_page.dart';

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
                  color: Colors.deepPurpleAccent, // 보라색으로 텍스트 색상 변경
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: ListTile(
                  leading: const Icon(Icons.email, color: Colors.deepPurpleAccent), // 아이콘 색상 변경
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: ListTile(
                  leading: const Icon(Icons.account_circle, color: Colors.deepPurpleAccent), // 아이콘 색상 변경
                  title: const Text('Sign-in Method'),
                  subtitle: Text(user.type),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: ListTile(
                  leading: const Icon(Icons.security, color: Colors.deepPurpleAccent), // 아이콘 색상 변경
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
                    backgroundColor: Colors.deepPurpleAccent, // 보라색 배경색으로 버튼 변경
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              const Divider(color: Colors.deepPurpleAccent), // 보라색으로 구분선 색상 변경
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurpleAccent), // 아이콘 색상 변경
                  title: const Text('Settings'),
                  onTap: () {
                    Get.off(SettingPage());
                  },
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 900),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.deepPurpleAccent), // 아이콘 색상 변경
                  title: const Text('My History'),
                  onTap: () {
                    showHistoryDialog(context, user.uid);
                  },
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: ListTile(
                  leading: const Icon(Icons.help, color: Colors.deepPurpleAccent), // 아이콘 색상 변경
                  title: const Text('Help & Support'),
                  onTap: () {
                    showHelpSupportDialog(context);
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
        style: TextStyle(color: Colors.deepPurpleAccent), // 보라색으로 텍스트 색상 변경
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.deepPurpleAccent), // 보라색으로 아이콘 색상 변경
    );
  }

  void showHistoryDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('My Travel Logs'),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('travel_logs')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var logs = snapshot.data!.docs;

              if (logs.isEmpty) {
                return Text('You have no travel logs.');
              }

              return SizedBox(
                width: double.maxFinite,
                height: 400, // 적절한 높이를 지정
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    var log = logs[index];

                    return ListTile(
                      title: Text(log['placeName']),
                      subtitle: Text(log['timestamp'].toDate().toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('travel_logs')
                              .doc(log.id)
                              .delete();
                          Navigator.of(context).pop();
                          showHistoryDialog(context, userId);
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TravelLogDetailPage(
                              imageUrls: log['imageUrls'],
                              rating: log['rating'],
                              review: log['review'],
                              placeName: log['placeName'],
                              timestamp: log['timestamp'].toDate(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 창 닫기
              },
              child: Text('Close', style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
          ],
        );
      },
    );
  }
}

class HelpSupportDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Help & Support'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: Text('FAQ'),
              children: [
                ListTile(
                  title: Text('계정을 어떻게 복구하나요?'),
                  subtitle: Text('계정 복구를 위해 설정 메뉴에서 비밀번호 재설정을 선택하세요.'),
                ),
                ListTile(
                  title: Text('비밀번호를 잊어버렸어요.'),
                  subtitle: Text('비밀번호 재설정을 위해 이메일을 통해 복구 링크를 받으세요.'),
                ),
                ListTile(
                  title: Text('어떻게 지원팀에 연락하나요?'),
                  subtitle: Text('고객 지원팀에 연락하려면 아래 연락처 정보를 참고하세요.'),
                ),
              ],
            ),
            Divider(),
            ExpansionTile(
              title: Text('Contact Us'),
              children: [
                ListTile(
                  title: Text('Email'),
                  subtitle: Text('support@yourapp.com'),
                ),
                ListTile(
                  title: Text('Phone'),
                  subtitle: Text('+82-1234-5678'),
                ),
              ],
            ),
            Divider(),
            ExpansionTile(
              title: Text('App Guide'),
              children: [
                ListTile(
                  title: Text('여행 일지 작성 방법'),
                  subtitle: Text('앱 내의 여행 일지 작성 기능을 사용하여 여행 일지를 기록할 수 있습니다.'),
                ),
                ListTile(
                  title: Text('지도 사용 방법'),
                  subtitle: Text('지도 기능을 통해 목적지에 쉽게 도착할 수 있습니다.'),
                ),
              ],
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('피드백 제공'),
              subtitle: Text('앱에 대한 피드백을 보내주세요. 여러분의 의견을 소중히 여깁니다.'),
              onTap: () {
                // 피드백 제공 기능으로 이동하는 코드 추가
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.policy),
              title: Text('Privacy Policy'),
              subtitle: Text('개인정보 보호정책을 읽어보세요.'),
              onTap: () {
                // 개인정보 보호정책 페이지로 이동하는 코드 추가
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report a Problem'),
              subtitle: Text('앱 사용 중 발생한 문제를 보고하세요.'),
              onTap: () {
                // 문제 보고 기능으로 이동하는 코드 추가
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업 창 닫기
          },
          child: Text('Close', style: TextStyle(color: Colors.deepPurpleAccent)),
        ),
      ],
    );
  }
}

void showHelpSupportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return HelpSupportDialog();
    },
  );
}
