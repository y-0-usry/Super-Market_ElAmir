import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../models/order_model.dart';
import '../../services/app_language.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null) {
        _nameController.text = userData.name;
        _phoneController.text = userData.phone;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final lang = Provider.of<AppLanguage>(context, listen: false).t;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('يجب تسجيل الدخول أولاً');
        }

        final cartProvider = Provider.of<CartProvider>(context, listen: false);

        final order = OrderModel(
          id: '',
          userId: user.uid,
          items: cartProvider.items
              .map((item) => OrderItem(
                    productId: item.productId,
                    productName: item.name,
                    productImage: item.image,
                    price: item.price,
                    quantity: item.quantity,
                  ))
              .toList(),
          totalPrice: cartProvider.totalPrice,
          customerName: _nameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          createdAt: DateTime.now(),
        );

        final orderId = await _orderService.createOrder(order);

        // Clear cart
        cartProvider.clearCart();

        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(lang('orderPlaced')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFF57C00),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text('${lang('orders')} #: $orderId'),
                  const SizedBox(height: 8),
                  Text(lang('willContact')),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(lang('ok')),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final lang = Provider.of<AppLanguage>(context).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang('checkout')),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Text(
                lang('orderSummary'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ...cartProvider.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} × ${item.quantity}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '${item.totalPrice} جنيه',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang('totalCart') + ':',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartProvider.totalPrice} جنيه',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Customer Details
              Text(
                lang('addressLabel'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: lang('fullName'),
                  labelStyle: const TextStyle(color: Colors.orange),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFF57C00)),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? lang('enterName') : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: lang('phone'),
                  labelStyle: const TextStyle(color: Colors.orange),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFFF57C00)),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang('enterPhone');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: lang('addressLabel'),
                  labelStyle: const TextStyle(color: Colors.orange),
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFFF57C00)),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang('enterAddress');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: lang('notesLabel'),
                  labelStyle: const TextStyle(color: Colors.orange),
                  prefixIcon: const Icon(Icons.note, color: Color(0xFFF57C00)),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'تأكيد الطلب',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
