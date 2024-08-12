class TabBarModel {
  final String title;
  final String location;
  final List<String> imageUrls;
  final double ratings;
  final String description;

  TabBarModel({required this.title,
    required this.location,
    required this.imageUrls,
    required this.ratings,
    required this.description,});

  Map<String, dynamic> toJson() =>
      {
        "title": title,
        "location": location,
        "image": imageUrls[0],
        "description": description,
        "imageUrls": imageUrls,
        "ratings": ratings,
      };

  factory TabBarModel.fromJson(Map<String, dynamic> json) {
    return TabBarModel(
        title: json['title'],
        location: json['location'],
        imageUrls: List<String>.from(json['imageUrls']),
        description: json['description'],
        ratings: json['ratings']
    );
  }
}
