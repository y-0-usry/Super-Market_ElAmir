import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role; // 'customer', 'admin', 'owner'
  final List<String> addresses;
  final String? profileImage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'customer',
    this.addresses = const [],
    this.profileImage,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'addresses': addresses,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  // Create from Firebase Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      addresses: List<String>.from(map['addresses'] ?? []),
      profileImage: map['profileImage'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: map['lastLogin'] != null ? (map['lastLogin'] as Timestamp).toDate() : null,
    );
  }

  // Copy with - for easy updates
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    List<String>? addresses,
    String? profileImage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      addresses: addresses ?? this.addresses,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
