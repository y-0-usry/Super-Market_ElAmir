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
    final key = _key(item.productId, item.flavorId);
    final index = _items.indexWhere((i) => _key(i.productId, i.flavorId) == key);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId, {String? flavorId}) {
    final key = _key(productId, flavorId);
    _items.removeWhere((item) => _key(item.productId, item.flavorId) == key);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity, {String? flavorId}) {
    final key = _key(productId, flavorId);
    int index = _items.indexWhere((i) => _key(i.productId, i.flavorId) == key);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String productId, {String? flavorId}) {
    final key = _key(productId, flavorId);
    int index = _items.indexWhere((i) => _key(i.productId, i.flavorId) == key);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId, {String? flavorId}) {
    final key = _key(productId, flavorId);
    int index = _items.indexWhere((i) => _key(i.productId, i.flavorId) == key);
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

  bool isInCart(String productId, {String? flavorId}) {
    final key = _key(productId, flavorId);
    return _items.any((item) => _key(item.productId, item.flavorId) == key);
  }

  int getQuantity(String productId, {String? flavorId}) {
    final key = _key(productId, flavorId);
    int index = _items.indexWhere((i) => _key(i.productId, i.flavorId) == key);
    return index >= 0 ? _items[index].quantity : 0;
  }

  String _key(String productId, String? flavorId) => '$productId|${flavorId ?? 'none'}';
}
