import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../models/order.dart';
import '../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  String? _selectedStatus;

  final List<Map<String, String>> _statuses = [
    {'value': 'pending', 'label': 'قيد الانتظار', 'color': '0xFFFF9800'},
    {'value': 'preparing', 'label': 'جاري التجهيز', 'color': '0xFF2196F3'},
    {'value': 'shipped', 'label': 'في الطريق', 'color': '0xFF9C27B0'},
    {'value': 'delivered', 'label': 'تم التسليم', 'color': '0xFFF57C00'},
    {'value': 'cancelled', 'label': 'ملغي', 'color': '0xFFf44336'},
  ];

  Color _getStatusColor(String status) {
    for (var s in _statuses) {
      if (s['value'] == status) {
        return Color(int.parse(s['color']!));
      }
    }
    return Colors.grey;
  }

  String _getStatusLabel(String status) {
    for (var s in _statuses) {
      if (s['value'] == status) {
        return s['label']!;
      }
    }
    return status;
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text('تفاصيل الطلب #${order.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('العميل:', order.customerName),
              _buildDetailRow('الهاتف:', order.phone),
              _buildDetailRow('العنوان:', order.address),
              if (order.notes != null) _buildDetailRow('ملاحظات:', order.notes!),
              _buildDetailRow(
                'التاريخ:',
                intl.DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt),
              ),
              const Divider(),
              const Text(
                'المنتجات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} × ${item.quantity}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          '${item.price * item.quantity} ج.م',
                          style: const TextStyle(
                            color: Color(0xFFF57C00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
              const Divider(),
              _buildDetailRow(
                'الإجمالي:',
                '${order.totalPrice} ج.م',
                isHighlight: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('تغيير حالة الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statuses
              .map((status) => ListTile(
                    title: Text(status['label']!),
                    selected: order.status == status['value'],
                    onTap: () async {
                      try {
                        await _orderService.updateOrderStatus(
                          order.id,
                          status['value']!,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تحديث حالة الطلب بنجاح'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('خطأ: $e')),
                          );
                        }
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFFF57C00) : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isHighlight ? const Color(0xFFF57C00) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Status filter
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1a1a1a),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('الكل'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) =>
                        setState(() => _selectedStatus = null),
                  ),
                  const SizedBox(width: 8),
                  ..._statuses.map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status['label']!),
                          selected: _selectedStatus == status['value'],
                          onSelected: (selected) => setState(
                            () => _selectedStatus =
                                selected ? status['value'] : null,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          // Orders list
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: _selectedStatus == null
                  ? _orderService.getOrders()
                  : _orderService.getOrdersByStatus(_selectedStatus!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }

                final orders = snapshot.data ?? [];

                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد طلبات',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        title: Text(
                          '${order.customerName} - #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                _getStatusLabel(order.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${intl.DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)} | ${order.totalPrice} ج.م',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('الهاتف:', order.phone),
                                _buildDetailRow('العنوان:', order.address),
                                if (order.notes != null)
                                  _buildDetailRow('ملاحظات:', order.notes!),
                                const Divider(),
                                const Text(
                                  'المنتجات:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...order.items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.productName} × ${item.quantity}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${item.price * item.quantity} ج.م',
                                            style: const TextStyle(
                                              color: Color(0xFFF57C00),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(),
                                _buildDetailRow(
                                  'الإجمالي:',
                                  '${order.totalPrice} ج.م',
                                  isHighlight: true,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showChangeStatusDialog(order),
                                      icon: const Icon(Icons.edit),
                                      label: const Text('تغيير الحالة'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showOrderDetails(order),
                                      icon: const Icon(Icons.info),
                                      label: const Text('التفاصيل'),
                                    ),
                                  ],
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
          ),
        ],
      ),
    );
  }
}
