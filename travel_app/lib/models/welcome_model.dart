class WelcomeModel {
  final String title;
  final String subTitle;
  final String description;
  final String imageUrl;

  WelcomeModel({
    required this.title,
    required this.subTitle,
    required this.description,
    required this.imageUrl,
  });
}

List<WelcomeModel> welcomeComponents = [
  WelcomeModel(
      title: "제주도",
      subTitle: "대한민국의 아름다운 섬",
      description:
          "대한민국의 아름다운 섬 제주도!",
      imageUrl: "assets/images/jeju.jpg"),
  WelcomeModel(
      title: "동부권",
      subTitle: "Seas",
      description:
          "",
      imageUrl: "assets/images/2.jpg"),
  WelcomeModel(
      title: "서부권",
      subTitle: "Mountains",
      description:
          "",
      imageUrl: "assets/images/3.jpg"),
];
