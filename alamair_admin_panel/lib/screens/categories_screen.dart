import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();

  void _showAddCategoryDialog([Category? category]) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final imageController = TextEditingController(text: category?.image ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(category == null ? 'إضافة قسم جديد' : 'تعديل القسم'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  hintText: 'مثال: خضروات',
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'رابط صورة القسم (اختياري)',
                  hintText: 'https://example.com/image.jpg',
                ),
                textDirection: TextDirection.ltr,
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
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال اسم القسم')),
                );
                return;
              }

              try {
                if (category == null) {
                  await _categoryService.addCategory(
                    Category(
                      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      image: imageController.text.trim().isEmpty
                          ? null
                          : imageController.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
                } else {
                  await _categoryService.updateCategory(category.id, {
                    'name': nameController.text.trim(),
                    'image': imageController.text.trim().isEmpty
                        ? null
                        : imageController.text.trim(),
                  });
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(category == null
                          ? 'تم إضافة القسم بنجاح'
                          : 'تم تعديل القسم بنجاح'),
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
            child: Text(category == null ? 'إضافة' : 'تعديل'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف القسم "${category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _categoryService.deleteCategory(category.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف القسم بنجاح')),
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
      body: StreamBuilder<List<Category>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد أقسام بعد\nاضغط + لإضافة قسم جديد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57C00).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddCategoryDialog(category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(category),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: const Color(0xFFF57C00),
        child: const Icon(Icons.add),
      ),
    );
  }
}
