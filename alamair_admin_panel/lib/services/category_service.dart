import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories
  Stream<List<Category>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add category
  Future<void> addCategory(Category category) async {
    final doc = _firestore.collection('categories').doc();
    await doc.set({
      'id': doc.id,
      ...category.toMap(),
    });
  }

  // Update category
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _firestore.collection('categories').doc(id).update(data);
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }
}
