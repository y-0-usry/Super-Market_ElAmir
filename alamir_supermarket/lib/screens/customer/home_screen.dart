import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/product_service.dart';
import '../../services/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../services/favorites_service.dart';
import '../../services/app_language.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/cart_item.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _selectedCategoryId;

  // Tabs exclude cart; cart is a floating action button
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomePage(),
      CategoriesPage(),
      OrdersScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context).t;
    return Scaffold(
      body: _selectedIndex == 0
          ? HomePage(
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (categoryId) {
                setState(() => _selectedCategoryId = categoryId);
              },
            )
          : _screens[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF57C00),
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
        child: const Icon(Icons.shopping_bag),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xFF1a1a1a),
        elevation: 12,
        child: SizedBox(
          height: 65,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFF57C00),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF1a1a1a),
            elevation: 0,
            iconSize: 24,
            selectedLabelStyle: const TextStyle(color: Color(0xFFF57C00), fontSize: 12),
            unselectedLabelStyle: const TextStyle(color: Colors.grey, fontSize: 11),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: lang('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.category_rounded),
                label: lang('categories'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_rounded),
                label: lang('orders'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: lang('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();
    final lang = Provider.of<AppLanguage>(context).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang('categories')),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: StreamBuilder<List<CategoryModel>>(
              stream: productService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final categories = snapshot.data!;
                if (categories.isEmpty) {
                  return Center(child: Text(lang('noProducts'))); 
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final selected = cat.id == _categoryId;
                    return GestureDetector(
                      onTap: () => setState(() => _categoryId = cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFF57C00) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: selected ? const Color(0xFFF57C00) : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 120,
                              child: Text(
                                '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected ? Colors.white70 : Colors.grey,
                                ),
                              ),
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
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _categoryId == null
                  ? productService.getProducts()
                  : productService.getProductsByCategory(_categoryId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!;
                if (products.isEmpty) {
                  return Center(child: Text(lang('noProducts')));
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return const Center(child: Text('سجل الدخول لعرض المنتجات'));
                }
                final favService = FavoritesService();

                return StreamBuilder<Set<String>>(
                  stream: favService.favoritesIds(user.uid),
                  builder: (context, favSnap) {
                    final favs = favSnap.data ?? <String>{};
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isFav = favs.contains(product.id);
                        return ProductCard(
                          product: product,
                          isFavorite: isFav,
                          onToggleFavorite: () => favService.toggleFavorite(user.uid, product.id),
                        );
                      },
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

class HomePage extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String?)? onCategorySelected;

  const HomePage({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  Future<void> _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();
    final cartProvider = Provider.of<CartProvider>(context);
    final lang = Provider.of<AppLanguage>(context).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang('home')),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'تسجيل خروج',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: lang('searchHint'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),

            // Featured Products Carousel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                lang('todaysDeals'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: StreamBuilder<List<ProductModel>>(
                stream: productService.getFeaturedProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return const Center(child: Text('لا توجد عروض حالياً'));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
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
                          width: 160,
                          margin: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a1a1a),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF57C00), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF57C00).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  product.image,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 50),
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${product.price} جنيه',
                                          style: const TextStyle(
                                            color: Color(0xFFF57C00),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (product.oldPrice != null) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '${product.oldPrice}',
                                            style: const TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
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
            const SizedBox(height: 24),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                lang('categories'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: StreamBuilder<List<CategoryModel>>(
                stream: productService.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = widget.selectedCategoryId == category.id;
                      return GestureDetector(
                        onTap: () {
                            widget.onCategorySelected?.call(
                              isSelected ? null : category.id,
                            );
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected 
                                ? const LinearGradient(
                                    colors: [Color(0xFFF57C00), Color(0xFFFB8C00)],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF57C00) : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFF57C00).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                category.image,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.category,
                                    size: 50,
                                    color: isSelected ? Colors.white : Colors.grey,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
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
            const SizedBox(height: 24),

            // Products List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.selectedCategoryId == null ? lang('allProducts') : lang('allProducts'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<ProductModel>>(
              stream: widget.selectedCategoryId == null
                  ? productService.getProducts()
                  : productService.getProductsByCategory(widget.selectedCategoryId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final products = snapshot.data!;
                final filtered = _query.isEmpty
                    ? products
                    : products
                        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(lang('noProducts')),
                    ),
                  );
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return const Center(child: Text('سجل الدخول لعرض المنتجات'));
                }

                final favService = FavoritesService();

                return StreamBuilder<Set<String>>(
                  stream: favService.favoritesIds(user.uid),
                  builder: (context, favSnap) {
                    final favs = favSnap.data ?? <String>{};
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        final isFav = favs.contains(product.id);
                        return ProductCard(
                          product: product,
                          isFavorite: isFav,
                          onToggleFavorite: () => favService.toggleFavorite(user.uid, product.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

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
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF57C00), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF57C00).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${product.price} جنيه',
                          style: const TextStyle(
                            color: Color(0xFFF57C00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.oldPrice != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${product.oldPrice}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          cartProvider.addItem(
                            CartItem(
                              productId: product.id,
                              name: product.name,
                              image: product.image,
                              price: product.price,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(Provider.of<AppLanguage>(context, listen: false).t('addedToCart')),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 2,
                        ),
                        child: Text(Provider.of<AppLanguage>(context, listen: false).t('addToCartShort'), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
