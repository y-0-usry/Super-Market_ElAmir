import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import '../../services/favorites_service.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../customer/home_screen.dart';
import '../../services/app_language.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _userData;
  bool _isLoading = true;
  String _language = 'ar';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await _authService.getUserData(user.uid);
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context).t;
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          backgroundColor: const Color(0xFFF57C00),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('يجب تسجيل الدخول أولاً'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF57C00), Color(0xFFE65100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _userData!.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: lang('editProfile'),
              onTap: () async {
                if (_userData != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(userData: _userData!),
                    ),
                  );
                  
                  // Reload user data if changes were saved
                  if (result == true) {
                    _loadUserData();
                  }
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: lang('myAddresses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.favorite_outline,
              title: lang('favorites'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: lang('settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen(
                    language: _language,
                    onLanguageChanged: (newLang) {
                      setState(() => _language = newLang);
                      // Update provider
                      Provider.of<AppLanguage>(context, listen: false).setLang(newLang);
                    },
                  )),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.headset_mic_outlined,
              title: lang('support'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: lang('about'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'الأمير سوبر ماركت',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('تطبيق الأمير سوبر ماركت لطلب المنتجات'),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            _buildMenuItem(
              icon: Icons.logout,
              title: lang('logout'),
              onTap: _signOut,
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('myAddresses')),
        backgroundColor: const Color(0xFFF57C00),
      ),
      body: Center(
        child: Text(lang.t('addYourAddress')),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context).t;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('سجل الدخول لعرض المفضلة')),
      );
    }
    final favService = FavoritesService();
    final productService = ProductService();

    return Scaffold(
      appBar: AppBar(title: Text(lang('favorites')), backgroundColor: const Color(0xFFF57C00)),
      body: StreamBuilder<Set<String>>(
        stream: favService.favoritesIds(user.uid),
        builder: (context, favSnap) {
          final favs = favSnap.data ?? <String>{};
          if (favs.isEmpty) {
            return Center(child: Text(lang('emptyFav')));
          }
          return StreamBuilder<List<ProductModel>>(
            stream: productService.getProducts(),
            builder: (context, prodSnap) {
              if (!prodSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = prodSnap.data!
                  .where((p) => favs.contains(p.id))
                  .toList();
              if (products.isEmpty) {
                return const Center(child: Text('لا توجد منتجات مفضلة')); 
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    isFavorite: true,
                    onToggleFavorite: () => favService.toggleFavorite(user.uid, product.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;

  const SettingsScreen({super.key, required this.language, required this.onLanguageChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentLang;

  @override
  void initState() {
    super.initState();
    _currentLang = widget.language;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('settings')),
        backgroundColor: const Color(0xFFF57C00),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(lang.t('language')),
            subtitle: Text(_currentLang == 'ar' ? lang.t('arabic') : lang.t('english')),
            trailing: DropdownButton<String>(
              value: _currentLang,
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('عربي')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null && val != _currentLang) {
                  lang.setLang(val);
                  widget.onLanguageChanged(val);
                  setState(() => _currentLang = val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context).t;
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('support')),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text(lang('supportBody'))),
    );
  }
}
