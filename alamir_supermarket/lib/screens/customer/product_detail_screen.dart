import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../services/cart_provider.dart';
import '../../services/product_service.dart';
import '../../services/favorites_service.dart';
import '../../models/cart_item.dart';
import '../../services/app_language.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final lang = Provider.of<AppLanguage>(context);
    final user = FirebaseAuth.instance.currentUser;
    final favService = FavoritesService();
    final productService = ProductService();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
        actions: [
          if (user != null)
            StreamBuilder<Set<String>>(
              stream: favService.favoritesIds(user.uid),
              builder: (context, snapshot) {
                final isFav = snapshot.data?.contains(product.id) ?? false;
                return IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  color: isFav ? Colors.redAccent : Colors.white,
                  onPressed: () => favService.toggleFavorite(user.uid, product.id),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Image.network(
              product.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 100),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        '${product.price} ${lang.t('currency')}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '${product.oldPrice} ${lang.t('currency')}',
                          style: const TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${((1 - product.price / product.oldPrice!) * 100).round()}% ${lang.t('discount')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Availability
                  Row(
                    children: [
                      Icon(
                        product.isAvailable ? Icons.check_circle : Icons.cancel,
                        color: product.isAvailable ? const Color(0xFFFF9800) : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang.t(product.isAvailable ? 'available' : 'outOfStock'),
                        style: TextStyle(
                          fontSize: 16,
                          color: product.isAvailable ? const Color(0xFFFF9800) : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    lang.t('description'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    lang.t('similarProducts'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<ProductModel>>(
                    stream: productService.getProductsByCategory(product.categoryId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final related = snapshot.data!
                          .where((p) => p.id != product.id)
                          .take(6)
                          .toList();
                      if (related.isEmpty) {
                        return Text(lang.t('noProducts'));
                      }
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 8),
                          itemCount: related.length,
                          itemBuilder: (context, index) {
                            final r = related[index];
                            return SizedBox(
                              width: 160,
                              child: _MiniProductCard(product: r),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: product.isAvailable
              ? () {
                  if (cartProvider.isInCart(product.id)) {
                    cartProvider.increaseQuantity(product.id);
                  } else {
                    cartProvider.addItem(
                      CartItem(
                        productId: product.id,
                        name: product.name,
                        image: product.image,
                        price: product.price,
                      ),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.t('addedToCart')),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            lang.t('addToCart'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _MiniProductCard extends StatelessWidget {
  final ProductModel product;
  const _MiniProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF57C00), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF57C00).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.image,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price} ${Provider.of<AppLanguage>(context, listen: false).t('currency')}',
                    style: const TextStyle(
                      color: Color(0xFFF57C00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
