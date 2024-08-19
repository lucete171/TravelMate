import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/people_also_like_model.dart';
import '../nav_pages.dart/main_wrapper.dart';
import '../pages/details_page.dart';
import '../widget/reuseable_text.dart';
import '../models/tab_bar_model.dart';
import '../widget/painter.dart';
import '../widget/reuseabale_middle_app_text.dart';
import '../nav_pages.dart/drawer_menu.dart';
import 'travel_log_page.dart';
import 'travel_log_detail.dart';
import 'category_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<TabBarModel> searchResults = [];

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
    } else {
      List<TabBarModel> results = await searchPlacesByName(query);
      setState(() {
        searchResults = results;
      });
    }
  }

  Future<List<TabBarModel>> searchPlacesByName(String query) async {
    List<TabBarModel> searchResults = [];
    try {
      QuerySnapshot visitAreaSnapshot = await FirebaseFirestore.instance
          .collection('visit_area_info')
          .where('VISIT_AREA_NM', isGreaterThanOrEqualTo: query)
          .where('VISIT_AREA_NM', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      for (var doc in visitAreaSnapshot.docs) {
        String title = doc['VISIT_AREA_NM'] ?? 'No Name';
        String location = doc['ROAD_NM_ADDR'] ?? doc['LOTNO_ADDR'];
        int visitAreaId = doc['VISIT_AREA_ID'];
        int visitAreaTypeCd = doc['VISIT_AREA_TYPE_CD'];
        double ratings = doc['DGSTFN'];

        QuerySnapshot photoSnapshot = await FirebaseFirestore.instance
            .collection('tn_tour_photo')
            .where('VISIT_AREA_ID', isEqualTo: visitAreaId)
            .limit(2)
            .get();

        QuerySnapshot codeSnapshot = await FirebaseFirestore.instance
            .collection('tc_codeb')
            .where('cd_a', isEqualTo: "VIS")
            .where('cd_b', isEqualTo: visitAreaTypeCd.toString())
            .limit(1)
            .get();

        String description = codeSnapshot.docs[0]['cd_nm'];

        List<String> fileNames = [];
        for (var photoDoc in photoSnapshot.docs) {
          String imageName = photoDoc['PHOTO_FILE_NM'] ?? 'No Image';
          fileNames.add(imageName);
        }

        List<String> imageUrls = await getImageUrls(fileNames);

        searchResults.add(TabBarModel(
          title: title,
          location: location,
          imageUrls: imageUrls,
          ratings: ratings,
          description: description,
        ));
      }
    } catch (e) {
      print("Error searching places: $e");
    }

    return searchResults;
  }


  late final TabController tabController;
  final EdgeInsetsGeometry padding =
  const EdgeInsets.symmetric(horizontal: 10.0);
  bool isLoading = true;
  List<TabBarModel> places = [];
  List<TabBarModel> inspiration = [];
  List<TabBarModel> festival = [];

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> ensureUserIsAuthenticated() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  Future<List<String>> getImageUrls(List<String> fileNames) async {
    List<String> imageUrls = [];
    for (String fileName in fileNames) {
      try {
        Reference storageReference = FirebaseStorage.instance.ref().child('photo/$fileName');
        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print("Error getting image URL: $e");
      }
    }
    return imageUrls;
  }

  void fetchData() async {
    await fetchCategoryData(places, [1, 2, 3, 12]);
    await fetchCategoryData(inspiration, [5, 6, 13]);
    await fetchCategoryData(festival, [8]);
  }

  Future<void> fetchCategoryData(List<TabBarModel> list, List<int> typeCodes) async {
    try {
      QuerySnapshot visitAreaSnapshot = await FirebaseFirestore.instance
          .collection('visit_area_info')
          .where('VISIT_AREA_TYPE_CD', whereIn: typeCodes)
          .limit(3) // 필요한 만큼의 데이터를 가져옵니다.
          .get();


      List<TabBarModel> tempList = [];

      for (var doc in visitAreaSnapshot.docs) {
        String title = doc['VISIT_AREA_NM'] ?? 'No Name';
        String location = doc['ROAD_NM_ADDR'] ?? doc['LOTNO_ADDR'];
        int visitAreaId = doc['VISIT_AREA_ID'];
        int visitAreaTypeCd = doc['VISIT_AREA_TYPE_CD'];
        double ratings = doc['DGSTFN'];

        // tn_tour_photo 컬렉션에서 VISIT_AREA_ID가 일치하는 문서 가져오기
        QuerySnapshot photoSnapshot = await FirebaseFirestore.instance
            .collection('tn_tour_photo')
            .where('VISIT_AREA_ID', isEqualTo: visitAreaId)
            .limit(2)
            .get();

        QuerySnapshot codeSnapshot = await FirebaseFirestore.instance
            .collection('tc_codeb')
            .where('cd_a', isEqualTo: "VIS")
            .where('cd_b', isEqualTo: visitAreaTypeCd.toString())
            .limit(1)
            .get();

        String description = codeSnapshot.docs[0]['cd_nm'];


        List<String> fileNames = [];
        if (photoSnapshot.docs.isNotEmpty) {
          for (var photoDoc in photoSnapshot.docs) {
            String imageName = photoDoc['PHOTO_FILE_NM'] ?? 'No Image';
            fileNames.add(imageName);
          }
        }

        List<String> imageUrls = await getImageUrls(fileNames);

        tempList.add(TabBarModel(
          title: title,
          location: location,
          imageUrls: imageUrls,
          ratings : ratings,
          description: description,
        ));
      }

      tempList.shuffle(Random());

      setState(() {
        list.addAll(tempList);
        isLoading = false; // 데이터 로딩 완료
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false; // 데이터 로딩 완료 (실패 시)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(size),
        drawer: const DrawerMenu(),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
          width: size.width,
          height: size.height,
          child: Padding(
            padding: padding,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: const AppText(
                      text: "Travel mate",
                      size: 35,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: const AppText(
                      text: "여행의 시작부터 끝까지",
                      size: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: size.height * 0.01, top: size.height * 0.02),
                      child: TextField(
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 240, 240, 240),
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.filter_alt_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          hintStyle: GoogleFonts.ubuntu(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                          hintText: "장소 검색",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: searchResults.isEmpty
                        ? Text("검색 결과가 없습니다.")
                        : Container(
                      height: size.height * 0.4,
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          TabBarModel current = searchResults[index];
                          return ListTile(
                            title: Text(current.title),
                            subtitle: Text(current.location),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                    personData: null,
                                    tabData: current,
                                    isCameFromPersonSection: false,
                                    imageUrls: current.imageUrls,
                                    rating: current.ratings,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Container(
                      margin: const EdgeInsets.only(top: 10.0),
                      width: size.width,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                          labelPadding: EdgeInsets.only(
                              left: size.width * 0.05,
                              right: size.width * 0.05),
                          controller: tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicator: const CircleTabBarIndicator(
                            color: Colors.deepPurpleAccent,
                            radius: 4,
                          ),
                          tabs: const [
                            Tab(
                              text: "Places",
                            ),
                            Tab(text: "Inspiration"),
                            Tab(text: "Festival"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: Container(
                      margin: EdgeInsets.only(top: size.height * 0.01),
                      width: size.width,
                      height: size.height * 0.4,
                      child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: tabController,
                          children: [
                            TabViewChild(
                              list: places,
                            ),
                            TabViewChild(list: inspiration),
                            TabViewChild(list: festival),
                          ]),
                    ),
                  ),
                  FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      child: const MiddleAppText(text: "More")),
                  FadeInUp(
                    delay: const Duration(milliseconds: 900),
                    child: Container(
                      margin: EdgeInsets.only(top: size.height * 0.01),
                      width: size.width,
                      height: size.height * 0.12,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryComponents.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          Category current = categoryComponents[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailPage(category: current),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(10.0),
                                  width: size.width * 0.16,
                                  height: size.height * 0.07,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image(
                                      image: AssetImage(
                                        current.image,
                                      ),
                                    ),
                                  ),
                                ),
                                AppText(
                                  text: current.name,
                                  size: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // 트래블러 스토리 섹션을 예쁘게 배치한 코드
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 아이콘과 텍스트 사이에 공간 배치
                      children: [
                        const MiddleAppText(
                          text: "Traveler Stories",
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.deepPurpleAccent,
                            size: 28, // 아이콘 크기 조절
                          ),
                          onPressed: () {
                            // 여행 기록 작성 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TravelLogPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  FadeInUp(
                    delay: const Duration(milliseconds: 1100),
                    child: Container(
                      margin: EdgeInsets.only(top: size.height * 0.01),
                      width: size.width,
                      height: size.height * 0.68,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('travel_logs')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final logs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: logs.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              var log = logs[index];
                              var timestamp = log['timestamp'] as Timestamp;
                              var date = timestamp.toDate();

                              return GestureDetector(
                                onTap: () {
                                  // 여행 기록의 상세 페이지로 이동하는 코드
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TravelLogDetailPage(
                                        imageUrls: log['imageUrls'],
                                        rating: log['rating'],
                                        review: log['review'],
                                        placeName: log['placeName'],
                                        timestamp: date,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0), // 간격 추가
                                  padding: const EdgeInsets.all(10.0), // 패딩 추가
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3), // 그림자 위치 조정
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: size.width * 0.28,
                                        height: size.height * 0.15, // 고정된 높이
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          image: DecorationImage(
                                            image: NetworkImage(log['imageUrls'][0]), // 첫 번째 이미지 사용
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log['placeName'], // 장소 이름 추가
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  '별점: ${log['rating']}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              log['review'],
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black.withOpacity(0.7),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '${date.year}-${date.month}-${date.day}', // 타임스탬프 출력
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
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
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(Size size) {
    return PreferredSize(
      preferredSize: Size.fromHeight(size.height * 0.09),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 5,
              ),
              child: GestureDetector(
                onTap: (() => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainWrapper()))),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/images/main.png"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TabViewChild extends StatelessWidget {
  const TabViewChild({
    required this.list,
    Key? key,
  }) : super(key: key);

  final List<TabBarModel> list;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ListView.builder(
      itemCount: list.length,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        TabBarModel current = list[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(
                personData: null,
                tabData: current,
                isCameFromPersonSection: false,
                imageUrls: [],
                rating: current.ratings,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Hero(
                tag: current.imageUrls[0],
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  width: size.width * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(current.imageUrls[0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: size.height * 0.2,
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  width: size.width * 0.53,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(153, 0, 0, 0),
                        Color.fromARGB(118, 29, 29, 29),
                        Color.fromARGB(54, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: size.width * 0.07,
                bottom: size.height * 0.045,
                child: AppText(
                  text: current.title,
                  size: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Positioned(
                left: size.width * 0.07,
                bottom: size.height * 0.025,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(
                      width: size.width * 0.01,
                    ),
                    AppText(
                      text: current.location,
                      size: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
