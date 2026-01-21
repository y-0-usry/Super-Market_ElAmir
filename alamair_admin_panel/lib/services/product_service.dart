import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), doc.id))
              .toList();
          // Local sorting to avoid composite index requirement
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return products;
        });
  }

  // Add product
  Future<void> addProduct(Product product) async {
    final doc = _firestore.collection('products').doc();
    await doc.set({
      ...product.toMap(),
      'id': doc.id,
    });
  }

  // Update product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _firestore.collection('products').doc(id).update(data);
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}
