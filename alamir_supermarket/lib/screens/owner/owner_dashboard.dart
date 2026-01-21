import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'manage_admins_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OwnerHomeScreen(),
    const ManageAdminsScreen(),
    const OwnerProductsScreen(),
    const OwnerOrdersScreen(),
    const OwnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المالك'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'لوحة التحكم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'المديرين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف',
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    
    if (!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

// Owner Home Screen
class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80, color: Color(0xFF2E7D32)),
          SizedBox(height: 20),
          Text(
            'مرحباً في لوحة تحكم المالك',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Owner Products Screen
class OwnerProductsScreen extends StatelessWidget {
  const OwnerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('إدارة المنتجات'),
    );
  }
}

// Owner Orders Screen
class OwnerOrdersScreen extends StatelessWidget {
  const OwnerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('إدارة الطلبات'),
    );
  }
}

// Owner Profile Screen
class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('الملف الشخصي'),
    );
  }
}
