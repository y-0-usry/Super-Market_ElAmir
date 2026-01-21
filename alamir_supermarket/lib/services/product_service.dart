import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList());
  }

  // Add category
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').doc(category.id).set(category.toMap());
    } catch (e) {
      print('Add category error: $e');
      rethrow;
    }
  }

  // Update category
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('categories').doc(id).update(data);
    } catch (e) {
      print('Update category error: $e');
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
    } catch (e) {
      print('Delete category error: $e');
      rethrow;
    }
  }

  // Get all products
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('=== getProducts: Got ${snapshot.docs.length} products from Firebase');
      final products = <ProductModel>[];
      for (var doc in snapshot.docs) {
        try {
          final product = ProductModel.fromMap(doc.data());
          products.add(product);
          print('✓ Parsed product: ${product.id} - ${product.name} (category: ${product.categoryId})');
        } catch (e) {
          print('✗ Failed to parse product: ${doc.id} - Error: $e');
        }
      }
      print('=== Total parsed products: ${products.length}');
      return products;
    });
  }

  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String categoryId) {
    print('=== getProductsByCategory called with: "$categoryId"');
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      print('=== Category "$categoryId": Got ${snapshot.docs.length} products from Firebase');
      final products = <ProductModel>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          print('   Document ${doc.id}: categoryId = "${data['categoryId']}"');
          final product = ProductModel.fromMap(data);
          products.add(product);
          print('   ✓ Parsed: ${product.name}');
        } catch (e) {
          print('   ✗ Failed to parse: ${doc.id} - Error: $e');
        }
      }
      print('=== Total products for category "$categoryId": ${products.length}');
      return products;
    });
  }

  // Get featured products
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _firestore
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList());
  }

  // Add product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toMap());
    } catch (e) {
      print('Add product error: $e');
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(id).update(data);
    } catch (e) {
      print('Update product error: $e');
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      print('Delete product error: $e');
      rethrow;
    }
  }

  // Get product by id
  Future<ProductModel?> getProductById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Get product error: $e');
    }
    return null;
  }

  // Search products
  Stream<List<ProductModel>> searchProducts(String query) {
    return _firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList());
  }
}
