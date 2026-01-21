import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  void addItem(CartItem item) {
    // Check if product already exists in cart
    int index = _items.indexWhere((i) => i.productId == item.productId);
    
    if (index >= 0) {
      // Increase quantity
      _items[index].quantity++;
    } else {
      // Add new item
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    int index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String productId) {
    int index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    int index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  int getQuantity(String productId) {
    int index = _items.indexWhere((i) => i.productId == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
