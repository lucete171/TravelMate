import '../models/tab_bar_model.dart';

class PeopleAlsoLikeModel extends TabBarModel {
  final String image;

  PeopleAlsoLikeModel({
    required super.title,
    required super.location,
    required super.imageUrls,
    required super.ratings,
    required super.description,
    required this.image,
  });

  Map<String, dynamic> toJson() =>
      {
        "title": title,
        "location": location,
        "image": imageUrls[0],
        "description": description,
        "imageUrls": imageUrls,
        "ratings": ratings,
      };

  factory PeopleAlsoLikeModel.fromJson(Map<String, dynamic> json) {
    return PeopleAlsoLikeModel(
        title: json['title'],
        location: json['location'],
        imageUrls: List<String>.from(json['imageUrls']),
        description: json['description'],
        ratings: json['ratings'],
        image: json['image'],
    );
  }
}

List<PeopleAlsoLikeModel> peopleAlsoLikeModel = [
  PeopleAlsoLikeModel(
      title: "Eiffel Tower",
      location: "Paris",
      image: "assets/images/paris.jpg",
      ratings: 0,
      description: "현대/건축",
  imageUrls: [],),
  PeopleAlsoLikeModel(
      title: "Baja Peninsula",
      location: "Mexico",
      image: "assets/images/images.jpeg",
      ratings: 0,
      description: "자연/해변",
      imageUrls: [],),
  PeopleAlsoLikeModel(
      title: "Sossusvlei",
      location: "Salt pan in Namibia",
      image: "assets/images/Sossusvlei.jpg",
      ratings: 0,
      description: "자연/사막",
      imageUrls: [],),
  PeopleAlsoLikeModel(
      title: "Cancún",
      location: "Mexico",
      image:
          "assets/images/22bab5ad4b9aa1027ad00a84ea7493d2c0c5e666d43d3b9413e332bdbd3f1780.jpg",
    ratings: 0,
      description: "자연/바다",
      imageUrls: [],),
];
