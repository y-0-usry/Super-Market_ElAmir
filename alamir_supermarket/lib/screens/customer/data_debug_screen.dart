import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class DataDebugScreen extends StatelessWidget {
  const DataDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('فحص البيانات'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section
            const Text(
              'الأقسام:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<CategoryModel>>(
              stream: productService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final categories = snapshot.data!;
                if (categories.isEmpty) {
                  return const Text('لا توجد أقسام في Firebase');
                }

                return Column(
                  children: categories.map((category) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.category, color: Color(0xFFF57C00)),
                        title: Text(category.name),
                        subtitle: Text('ID: ${category.id}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Show products for this category
                            _showCategoryProducts(context, category.id, productService);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF57C00),
                          ),
                          child: const Text('عرض المنتجات'),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // All Products Section
            const Text(
              'جميع المنتجات:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<ProductModel>>(
              stream: productService.getProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final products = snapshot.data!;
                if (products.isEmpty) {
                  return const Text('لا توجد منتجات في Firebase');
                }

                return Column(
                  children: products.map((product) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: product.image.isNotEmpty
                            ? Image.network(
                                product.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image, size: 50);
                                },
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('السعر: ${product.price} جنيه'),
                            Text('Category ID: ${product.categoryId}'),
                            Text('متوفر: ${product.isAvailable ? "نعم" : "لا"}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryProducts(BuildContext context, String categoryId, ProductService productService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'منتجات القسم: $categoryId',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<List<ProductModel>>(
                    stream: productService.getProductsByCategory(categoryId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final products = snapshot.data!;
                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inbox_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد منتجات لهذا القسم\nتأكد أن categoryId = $categoryId',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            child: ListTile(
                              leading: product.image.isNotEmpty
                                  ? Image.network(
                                      product.image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image);
                                      },
                                    )
                                  : const Icon(Icons.image),
                              title: Text(product.name),
                              subtitle: Text('${product.price} جنيه'),
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
        },
      ),
    );
  }
}
