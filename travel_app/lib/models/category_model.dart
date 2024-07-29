class Category {
  final String name;
  final String image;
  

  Category({required this.name, required this.image,});
}

List<Category> categoryComponents = [
  Category(name: "숙박", image: "assets/images/beach.png"),
  Category(name: "교통", image: "assets/images/boat.png"),
  Category(name: "음식집", image: "assets/images/museum.png"),
  Category(name: "카페", image: "assets/images/lake.png"),
  Category(name: "놀거리", image: "assets/images/tricycle.png"),
 
];
