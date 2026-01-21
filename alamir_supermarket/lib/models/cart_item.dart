class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] is int) ? map['quantity'] : (map['quantity'] as num).toInt(),
    );
  }
}
