class Order {
  final String id;
  final String userId;
  final String customerName;
  final String phone;
  final String address;
  final String? notes;
  final String paymentMethod; // cash, instapay, vodafone
  final List<OrderItem> items;
  final double totalPrice;
  final String status; // pending, preparing, shipped, delivered, cancelled
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.address,
    this.notes,
    this.paymentMethod = 'cash',
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    double _parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    List<OrderItem> items = [];
    try {
      if (map['items'] != null && map['items'] is List) {
        items = (map['items'] as List)
            .map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return OrderItem.fromMap(item);
                } else {
                  print('Warning: Order item is not a map: $item');
                }
              } catch (e) {
                print('Error parsing OrderItem: $e');
              }
              return null;
            })
            .whereType<OrderItem>()
            .toList();
      }
    } catch (e) {
      print('Error parsing items list: $e');
    }

    return Order(
      id: id,
      userId: map['userId'] ?? '',
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? map['customerPhone'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'],
      paymentMethod: map['paymentMethod']?.toString() ?? 'cash',
      items: items,
      totalPrice: _parsePrice(map['totalPrice']),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? flavorId;
  final String? flavorName;
  final String? flavorImage;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.flavorId,
    this.flavorName,
    this.flavorImage,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    double _parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 1;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 1;
      return 1;
    }

    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: _parsePrice(map['price']),
      quantity: _parseInt(map['quantity']),
      flavorId: map['flavorId']?.toString(),
      flavorName: map['flavorName']?.toString(),
      flavorImage: map['flavorImage']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'flavorId': flavorId,
      'flavorName': flavorName,
      'flavorImage': flavorImage,
    };
  }
}
