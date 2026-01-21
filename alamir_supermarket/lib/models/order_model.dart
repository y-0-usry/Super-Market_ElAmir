import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status; // pending, preparing, shipped, delivered, cancelled
  final String customerName;
  final String customerPhone;
  final String address;
  final String? notes;
  final DateTime createdAt;
  final DateTime? deliveryTime;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    this.status = 'pending',
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.notes,
    required this.createdAt,
    this.deliveryTime,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'address': address,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryTime': deliveryTime != null ? Timestamp.fromDate(deliveryTime!) : null,
    };
  }

  // Create from Firebase Document
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    try {
      // Safely parse items
      List<OrderItem> items = [];
      if (map['items'] != null && map['items'] is List) {
        items = (map['items'] as List)
            .map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return OrderItem.fromMap(item);
                }
              } catch (e) {
                print('Error parsing OrderItem: $e');
              }
              return null;
            })
            .whereType<OrderItem>()
            .toList();
      }

      return OrderModel(
        id: map['id']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        items: items,
        totalPrice: _parseDouble(map['totalPrice']),
        status: map['status']?.toString() ?? 'pending',
        customerName: map['customerName']?.toString() ?? '',
        customerPhone: map['customerPhone']?.toString() ?? '',
        address: map['address']?.toString() ?? '',
        notes: map['notes']?.toString(),
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        deliveryTime: map['deliveryTime'] is Timestamp
            ? (map['deliveryTime'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      print('Error parsing OrderModel: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    try {
      return OrderItem(
        productId: map['productId']?.toString() ?? '',
        productName: map['productName']?.toString() ?? '',
        productImage: map['productImage']?.toString() ?? '',
        price: _parseDouble(map['price']),
        quantity: _parseInt(map['quantity']),
      );
    } catch (e) {
      print('Error parsing OrderItem: $e');
      print('Map data: $map');
      rethrow;
    }
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
}
