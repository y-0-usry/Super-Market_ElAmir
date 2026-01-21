import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String image;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firebase Document
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
