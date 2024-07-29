import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category_model.dart';
import '../models/people_also_like_model.dart';
import '../nav_pages.dart/main_wrapper.dart';
import '../pages/details_page.dart';
import '../widget/reuseable_text.dart';
import '../models/tab_bar_model.dart';
import '../widget/painter.dart';
import '../widget/reuseabale_middle_app_text.dart';
import '../nav_pages.dart/drawer_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
          .limit(4) // 필요한 만큼의 데이터를 가져옵니다.
          .get();


      List<TabBarModel> tempList = [];

      for (var doc in visitAreaSnapshot.docs) {
        String title = doc['VISIT_AREA_NM'] ?? 'No Name';
        String location = doc['ROAD_NM_ADDR'] ?? doc['LOTNO_ADDR'];
        int visitAreaId = doc['VISIT_AREA_ID'];
        int visitAreaTypeCd = doc['VISIT_AREA_TYPE_CD'];

        print(visitAreaTypeCd);

        // tn_tour_photo 컬렉션에서 VISIT_AREA_ID가 일치하는 문서 가져오기
        QuerySnapshot photoSnapshot = await FirebaseFirestore.instance
            .collection('tn_tour_photo')
            .where('VISIT_AREA_ID', isEqualTo: visitAreaId)
            .limit(3)
            .get();

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
                            return Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(10.0),
                                  width: size.width * 0.16,
                                  height: size.height * 0.07,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.2),
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
                                )
                              ],
                            );
                          }),
                    ),
                  ),
                  FadeInUp(
                      delay: const Duration(milliseconds: 1000),
                      child: const MiddleAppText(text: "Traveler Stories")),
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
                            PeopleAlsoLikeModel current =
                                peopleAlsoLikeModel[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                    personData: current,
                                    tabData: null,
                                    isCameFromPersonSection: true,
                                    imageUrls: [],
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
                                      tag: current.day,
                                      child: Container(
                                        margin: const EdgeInsets.all(8.0),
                                        width: size.width * 0.28,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              current.image,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: size.width * 0.02),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: size.height * 0.035,
                                          ),
                                          AppText(
                                            text: current.title,
                                            size: 17,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.005,
                                          ),
                                          AppText(
                                            text: current.location,
                                            size: 14,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontWeight: FontWeight.w300,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: size.height * 0.015),
                                            child: AppText(
                                              text: "${current.day} Day",
                                              size: 14,
                                              color:
                                                  Colors.black.withOpacity(0.5),
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
                          }),
                    ),
                  )
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
