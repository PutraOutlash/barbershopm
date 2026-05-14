class FaceShape {
  final int id;
  final String name;
  final String description;
  final String suggestions;
  final String icon;

  FaceShape({
    required this.id,
    required this.name,
    required this.description,
    required this.suggestions,
    required this.icon,
  });

  factory FaceShape.fromJson(Map<String, dynamic> json) {
    return FaceShape(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      suggestions: json['suggestions'],
      icon: json['icon'],
    );
  }
}

class Hairstyle {
  final int id;
  final String name;
  final String category;
  final String image;
  final String? description;

  Hairstyle({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    this.description,
  });

  factory Hairstyle.fromJson(Map<String, dynamic> json) {
    return Hairstyle(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      image: json['image'],
      description: json['description'],
    );
  }
}
