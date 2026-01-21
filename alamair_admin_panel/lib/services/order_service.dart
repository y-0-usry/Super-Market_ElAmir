import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart' as order_model;

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all orders
  Stream<List<order_model.Order>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => order_model.Order.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get orders by status (with local sorting to avoid index requirement)
  Stream<List<order_model.Order>> getOrdersByStatus(String status) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => order_model.Order.fromMap(doc.data(), doc.id))
              .toList();
          // Sort locally instead of in Firestore query
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
  }

  // Delete order
  Future<void> deleteOrder(String id) async {
    await _firestore.collection('orders').doc(id).delete();
  }
}
