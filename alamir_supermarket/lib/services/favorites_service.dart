import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Set<String>> favoritesIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> toggleFavorite(String userId, String productId) async {
    final doc = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId);
    final exists = (await doc.get()).exists;
    if (exists) {
      await doc.delete();
    } else {
      await doc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'productId': productId,
      });
    }
  }
}
