import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_provider.dart';
import 'checkout_screen.dart';
import '../../services/app_language.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context).t;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(lang('cart')),
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang('cartEmpty'),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${lang('cart')} (${cartProvider.itemCount})'),
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('تأكيد'),
                      content: Text(lang('cancelQuestion')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(lang('no')),
                        ),
                        TextButton(
                          onPressed: () {
                            cartProvider.clearCart();
                            Navigator.pop(context);
                          },
                          child: Text(
                            lang('yes'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: const Color(0xFF2a2a2a),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.image,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 80,
                                    width: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.price} جنيه',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFF57C00),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.flavorName != null && item.flavorName!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'النكهة: ${item.flavorName}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // Quantity controls
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 16),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                              onPressed: () {
                                                cartProvider.decreaseQuantity(item.productId, flavorId: item.flavorId);
                                              },
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 16),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                              onPressed: () {
                                                cartProvider.increaseQuantity(item.productId, flavorId: item.flavorId);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      // Total price
                                      Flexible(
                                        child: Text(
                                          '${item.totalPrice} جنيه',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFF57C00),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                cartProvider.removeItem(item.productId, flavorId: item.flavorId);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           lang('total') + ':',
                           style: const TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: Colors.white,
                           ),
                         ),
                         Text(
                           '${cartProvider.totalPrice} جنيه',
                           style: const TextStyle(
                             fontSize: 24,
                             fontWeight: FontWeight.bold,
                             color: Color(0xFFF57C00),
                           ),
                         ),
                       ],
                     ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFFF57C00),
                           foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                         child: Text(
                           lang('checkout'),
                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                         ),
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
  }
}
