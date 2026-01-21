class Product {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final double? oldPrice;
  final String image;
  final String description;
  final int quantity;
  final bool isAvailable;
  final bool isFeatured;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.oldPrice,
    required this.image,
    required this.description,
    this.quantity = 0,
    this.isAvailable = true,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    double _parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    double? _parseOptionalPrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value > 0 ? value : null;
      if (value is int) return value > 0 ? value.toDouble() : null;
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed != null && parsed > 0 ? parsed : null;
      }
      return null;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Product(
      id: id,
      name: map['name'] ?? '',
      categoryId: map['categoryId'] ?? '',
      price: _parsePrice(map['price']),
      oldPrice: _parseOptionalPrice(map['oldPrice']),
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      quantity: _parseInt(map['quantity']),
      isAvailable: map['isAvailable'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'oldPrice': oldPrice,
      'image': image,
      'description': description,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'createdAt': createdAt,
    };
  }
}
