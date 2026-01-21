import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  String? _selectedCategoryId;

  void _showAddProductDialog([Product? product]) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final oldPriceController =
        TextEditingController(text: product?.oldPrice?.toString() ?? '');
    final imageController = TextEditingController(text: product?.image ?? '');
    String? selectedCategoryId = product?.categoryId;
    bool isAvailable = product?.isAvailable ?? true;
    bool isFeatured = product?.isFeatured ?? false;
    bool hasOldPrice = product?.oldPrice != null && product!.oldPrice! > 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: Text(product == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم المنتج'),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'السعر'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('إضافة سعر قديم (للخصم)'),
                  value: hasOldPrice,
                  onChanged: (val) {
                    setState(() {
                      hasOldPrice = val ?? false;
                      if (!hasOldPrice) {
                        oldPriceController.clear();
                      }
                    });
                  },
                ),
                if (hasOldPrice) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: oldPriceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر القديم',
                      hintText: 'السعر الأصلي قبل الخصم',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'رابط الصورة'),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<Category>>(
                  stream: _categoryService.getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('تحميل الأقسام...');
                    }
                    final categories = snapshot.data!;
                    return DropdownButton<String>(
                      value: selectedCategoryId,
                      hint: const Text('اختر قسم'),
                      isExpanded: true,
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedCategoryId = val),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('متوفر'),
                  value: isAvailable,
                  onChanged: (val) => setState(() => isAvailable = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text('منتج مميز'),
                  value: isFeatured,
                  onChanged: (val) => setState(() => isFeatured = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty ||
                    selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('يرجى ملء جميع الحقول المطلوبة')),
                  );
                  return;
                }

                try {
                  if (product == null) {
                    await _productService.addProduct(
                      Product(
                        id: '',
                        name: nameController.text.trim(),
                        categoryId: selectedCategoryId!,
                        price: double.parse(priceController.text.trim()),
                        oldPrice: hasOldPrice && oldPriceController.text.trim().isNotEmpty
                            ? double.parse(oldPriceController.text.trim())
                            : null,
                        image: imageController.text.trim(),
                        description: descController.text.trim(),
                        isAvailable: isAvailable,
                        isFeatured: isFeatured,
                        createdAt: DateTime.now(),
                      ),
                    );
                  } else {
                    await _productService.updateProduct(product.id, {
                      'name': nameController.text.trim(),
                      'categoryId': selectedCategoryId,
                      'price': double.parse(priceController.text.trim()),
                      'oldPrice': hasOldPrice && oldPriceController.text.trim().isNotEmpty
                          ? double.parse(oldPriceController.text.trim())
                          : null,
                      'image': imageController.text.trim(),
                      'description': descController.text.trim(),
                      'isAvailable': isAvailable,
                      'isFeatured': isFeatured,
                    });
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(product == null
                            ? 'تم إضافة المنتج بنجاح'
                            : 'تم تعديل المنتج بنجاح'),
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
              child: Text(product == null ? 'إضافة' : 'تعديل'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _productService.deleteProduct(product.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المنتج بنجاح')),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
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
          // Category filter
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1a1a1a),
            child: StreamBuilder<List<Category>>(
              stream: _categoryService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final categories = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('الكل'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) =>
                            setState(() => _selectedCategoryId = null),
                      ),
                      const SizedBox(width: 8),
                      ...categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat.name),
                              selected: _selectedCategoryId == cat.id,
                              onSelected: (selected) => setState(
                                () => _selectedCategoryId =
                                    selected ? cat.id : null,
                              ),
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
          // Products list
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _selectedCategoryId == null
                  ? _productService.getProducts()
                  : _productService.getProductsByCategory(_selectedCategoryId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد منتجات\nاضغط + لإضافة منتج جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Product image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[800],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.price} ج.م',
                                    style: const TextStyle(
                                      color: Color(0xFFF57C00),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      if (product.isAvailable)
                                        const Chip(
                                          label: Text(
                                            'متوفر',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          backgroundColor:
                                              Color(0xFFF57C00),
                                        ),
                                      if (product.isFeatured)
                                        const Chip(
                                          label: Text(
                                            'مميز',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          backgroundColor: Colors.blue,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Actions
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () =>
                                      _showAddProductDialog(product),
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف',
                                      style: TextStyle(color: Colors.red)),
                                  onTap: () => _deleteProduct(product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: const Color(0xFFF57C00),
        child: const Icon(Icons.add),
      ),
    );
  }
}
