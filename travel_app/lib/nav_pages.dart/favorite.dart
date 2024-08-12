import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../models/people_also_like_model.dart';
import '../widget/reuseabale_middle_app_text.dart';
import '../widget/reuseable_text.dart';
import '../pages/details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatelessWidget {
  Future<List<PeopleAlsoLikeModel>> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favorites = prefs.getStringList('favorites') ?? [];

      return favorites.map((item) {
        try {
          // JSON 데이터를 디코드하고 PeopleAlsoLikeModel로 변환
          return PeopleAlsoLikeModel.fromJson(
            Map<String, dynamic>.from(json.decode(item)),
          );
        } catch (e) {
          // 파싱 오류가 발생할 경우 처리
          print('Error parsing item: $e');
          return null; // 문제 있는 항목은 null로 처리
        }
      }).where((item) => item != null).cast<PeopleAlsoLikeModel>().toList(); // null 항목 필터링
    } catch (e) {
      // 전체 로딩 실패 시 에러 메시지 출력
      print('Error loading favorites: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: FutureBuilder<List<PeopleAlsoLikeModel>>(
        future: _loadFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorites found'));
          }

          List<PeopleAlsoLikeModel> peopleAlsoLikeModel = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: const MiddleAppText(text: "My favorite places"),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 1100),
                child: Container(
                  margin: EdgeInsets.only(top: size.height * 0.01),
                  width: size.width,
                  height: size.height * 0.68,
                  child: ListView.builder(
                    itemCount: peopleAlsoLikeModel.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      PeopleAlsoLikeModel current = peopleAlsoLikeModel[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              personData: current,
                              tabData: null,
                              isCameFromPersonSection: true,
                              imageUrls: current.imageUrls,
                              rating: current.ratings,
                            ),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          width: size.width,
                          height: size.height * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: current.description,
                                child: Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: size.width * 0.28,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: NetworkImage(current.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: size.width * 0.02),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: size.height * 0.035),
                                    AppText(
                                      text: current.title,
                                      size: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    AppText(
                                      text: current.location,
                                      size: 12,
                                      color: Colors.black.withOpacity(0.7),
                                      fontWeight: FontWeight.w300,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: size.height * 0.015),
                                      child: AppText(
                                        text: current.description,
                                        size: 14,
                                        color: Colors.black.withOpacity(0.5),
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
