/// User model representing a CareLink system user
/// Supports multiple roles: Resident/Carer, Care Coordinator, Support Worker, Safeguarding Reviewer
class User {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'RESIDENT', 'COORDINATOR', 'SUPPORT_WORKER', 'REVIEWER'
  final String? phoneNumber;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.address,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create User from database map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      phoneNumber: map['phone_number'] as String?,
      address: map['address'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert User to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone_number': phoneNumber,
      'address': address,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, role: $role)';
}
