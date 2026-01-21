import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _phoneController = TextEditingController(text: widget.userData.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _authService.updateUserData(user.uid, {
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ التغييرات بنجاح'),
                backgroundColor: Color(0xFFF57C00),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate changes were saved
          }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFF57C00),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  labelStyle: const TextStyle(color: Colors.orange),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFF57C00)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  labelStyle: const TextStyle(color: Colors.orange),
                  prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFFF57C00)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (read-only)
              TextFormField(
                initialValue: widget.userData.email,
                enabled: false,
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  labelStyle: const TextStyle(color: Colors.orange),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFF57C00)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                        'حفظ التغييرات',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
