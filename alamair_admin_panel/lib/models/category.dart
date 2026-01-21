class Category {
  final String id;
  final String name;
  final String? image;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.image,
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: map['id'] ?? id,
      name: map['name'] ?? '',
      image: map['image'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'createdAt': createdAt,
    };
  }
}
