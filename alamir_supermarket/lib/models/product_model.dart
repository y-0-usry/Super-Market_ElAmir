import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String image;
  final List<String> images;
  final String categoryId;
  final int quantity;
  final bool isAvailable;
  final bool isFeatured;
  final double rating; // تقييم المنتج
  final int reviewCount; // عدد التقييمات
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.image,
    this.images = const [],
    required this.categoryId,
    required this.quantity,
    this.isAvailable = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  // حساب الخصم كنسبة مئوية
  double get discountPercentage {
    if (oldPrice == null || oldPrice == 0 || price >= oldPrice!) return 0;
    final discount = ((oldPrice! - price) / oldPrice! * 100);
    if (discount.isNaN || discount.isInfinite) return 0;
    return discount;
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'image': image,
      'images': images,
      'categoryId': categoryId,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firebase Document
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    try {
      return ProductModel(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        price: _parseDouble(map['price']),
        oldPrice: map['oldPrice'] != null ? _parseDouble(map['oldPrice']) : null,
        image: map['image']?.toString() ?? '',
        images: _parseStringList(map['images']),
        categoryId: map['categoryId']?.toString() ?? '',
        quantity: _parseInt(map['quantity']),
        isAvailable: map['isAvailable'] == true || map['isAvailable']?.toString() == 'true',
        isFeatured: map['isFeatured'] == true || map['isFeatured']?.toString() == 'true',
        rating: _parseDouble(map['rating']),
        reviewCount: _parseInt(map['reviewCount']),
        createdAt: map['createdAt'] != null 
            ? (map['createdAt'] as Timestamp).toDate() 
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing product: $e');
      print('Product data: $map');
      rethrow;
    }
  }

  // Copy with
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? oldPrice,
    String? image,
    List<String>? images,
    String? categoryId,
    int? quantity,
    bool? isAvailable,
    bool? isFeatured,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      image: image ?? this.image,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }
}
