import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../services/app_language.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _getStatusText(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return Provider.of<AppLanguage>(context, listen: false).t('pending');
      case 'preparing':
        return Provider.of<AppLanguage>(context, listen: false).t('preparing');
      case 'shipped':
        return Provider.of<AppLanguage>(context, listen: false).t('shipped');
      case 'delivered':
        return Provider.of<AppLanguage>(context, listen: false).t('delivered');
      case 'cancelled':
        return Provider.of<AppLanguage>(context, listen: false).t('cancelled');
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return const Color(0xFFF57C00);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();
    final user = FirebaseAuth.instance.currentUser;
    final lang = Provider.of<AppLanguage>(context).t;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(lang('orders')),
          backgroundColor: const Color(0xFFF57C00),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(lang('mustLogin')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lang('orders')),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getUserOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang('ordersEmpty'),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: const Color(0xFF1a1a1a),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                  title: Text(
                    '${lang('orders')} #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(context, order.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${order.totalPrice} جنيه',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang('allProducts'),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          ...order.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.productName} × ${item.quantity}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      '${item.price * item.quantity} جنيه',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF57C00),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 12),
                          Text(
                            lang('address') + ':',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(order.address, style: const TextStyle(color: Colors.grey)),
                          if (order.notes != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              lang('notes') + ':',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(order.notes!, style: const TextStyle(color: Colors.grey)),
                          ],
                          const SizedBox(height: 12),
                          if (order.status == 'pending')
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(lang('cancelOrder')),
                                      content: Text(lang('cancelQuestion')),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(lang('no')),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(
                                            lang('yes'),
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    await orderService.cancelOrder(order.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('تم إلغاء الطلب'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('إلغاء الطلب'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
