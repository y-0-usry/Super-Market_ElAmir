import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class _ProductUpdate {
  final DocumentReference ref;
  final int newQuantity;

  _ProductUpdate(this.ref, this.newQuantity);
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new order with transaction
  Future<String> createOrder(OrderModel order) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Create order document reference
        DocumentReference orderRef = _firestore.collection('orders').doc();

        // 1) Read all product docs first (Firestore transaction requires reads before writes)
        final List<_ProductUpdate> updates = [];
        for (var item in order.items) {
          DocumentReference productRef = _firestore.collection('products').doc(item.productId);
          DocumentSnapshot productSnapshot = await transaction.get(productRef);

          if (!productSnapshot.exists) {
            throw Exception('منتج ${item.productName} غير موجود');
          }

          final data = productSnapshot.data() as Map<String, dynamic>;
          final int currentQuantity = _parseInt(data['quantity']);
          
          // Skip quantity check if quantity field is 0 or not set (unlimited stock)
          if (currentQuantity > 0) {
            final int newQuantity = currentQuantity - item.quantity;
            
            if (newQuantity < 0) {
              throw Exception('منتج ${item.productName} غير متوفر بالكمية المطلوبة');
            }
            
            updates.add(_ProductUpdate(productRef, newQuantity));
          }
        }

        // 2) After all reads, perform writes
        // Update order with generated ID
        OrderModel updatedOrder = OrderModel(
          id: orderRef.id,
          userId: order.userId,
          items: order.items,
          totalPrice: order.totalPrice,
          status: order.status,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          address: order.address,
          notes: order.notes,
          createdAt: order.createdAt,
          deliveryTime: order.deliveryTime,
        );

        // Set order data
        transaction.set(orderRef, updatedOrder.toMap());

        // Update product quantities
        for (final u in updates) {
          transaction.update(u.ref, {
            'quantity': u.newQuantity,
            'isAvailable': u.newQuantity > 0,
          });
        }

        return orderRef.id;
      });
    } catch (e) {
      print('Create order error: $e');
      rethrow;
    }
  }

  // Get orders by user ID (without index - local filtering)
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) {
          final allOrders = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data()))
              .toList();
          
          // Filter locally
          return allOrders
              .where((order) => order.userId == userId)
              .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
  }

  // Get all orders (for admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList());
  }

  // Get orders by status
  Stream<List<OrderModel>> getOrdersByStatus(String status) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList());
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      print('Update order status error: $e');
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // === STEP 1: ALL READS FIRST ===
        
        // Read the order
        DocumentReference orderRef = _firestore.collection('orders').doc(orderId);
        DocumentSnapshot orderSnapshot = await transaction.get(orderRef);

        if (!orderSnapshot.exists) {
          throw Exception('الطلب غير موجود');
        }

        final orderData = orderSnapshot.data() as Map<String, dynamic>;
        final String currentStatus = orderData['status'];

        // Only allow cancellation if status is pending
        if (currentStatus != 'pending') {
          throw Exception('لا يمكن إلغاء طلب في حالة $currentStatus');
        }

        // Read all products
        final List<dynamic> items = orderData['items'] ?? [];
        final Map<DocumentReference, int> productUpdates = {};
        
        for (var item in items) {
          final String productId = item['productId'] ?? '';
          final int quantity = _parseInt(item['quantity']);

          if (productId.isNotEmpty) {
            DocumentReference productRef = _firestore.collection('products').doc(productId);
            DocumentSnapshot productSnapshot = await transaction.get(productRef);

            if (productSnapshot.exists) {
              final data = productSnapshot.data() as Map<String, dynamic>;
              final int currentQuantity = _parseInt(data['quantity']);
              final int newQuantity = currentQuantity + quantity;
              
              productUpdates[productRef] = newQuantity;
            }
          }
        }

        // === STEP 2: ALL WRITES AFTER ===
        
        // Update order status
        transaction.update(orderRef, {
          'status': 'cancelled',
        });

        // Update product quantities
        productUpdates.forEach((productRef, newQuantity) {
          transaction.update(productRef, {
            'quantity': newQuantity,
            'isAvailable': true,
          });
        });
      });
    } catch (e) {
      print('Cancel order error: $e');
      rethrow;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Get order error: $e');
    }
    return null;
  }

  // Get today's orders count
  Future<int> getTodayOrdersCount() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print('Get today orders count error: $e');
      return 0;
    }
  }

  // Get today's sales
  Future<double> getTodaySales() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', whereIn: ['delivered', 'preparing', 'shipped'])
          .get();
      
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data() as Map<String, dynamic>)['totalPrice'] ?? 0;
      }
      
      return total;
    } catch (e) {
      print('Get today sales error: $e');
      return 0;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
