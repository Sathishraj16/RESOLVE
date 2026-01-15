enum UserRole {
  citizen,
  official,
  admin,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final String? department;
  final String? designation;
  final String? password; // For officials/admins only
  final DateTime? createdAt;
  final int? complaintsFiled;
  final int? complaintsResolved;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.role,
    this.department,
    this.designation,
    this.password,
    DateTime? createdAt,
    this.complaintsFiled,
    this.complaintsResolved,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.citizen,
      ),
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      password: json['password'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      complaintsFiled: json['complaintsFiled'] as int?,
      complaintsResolved: json['complaintsResolved'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'department': department,
      'designation': designation,
      'password': password,
      'createdAt': createdAt?.toIso8601String(),
      'complaintsFiled': complaintsFiled,
      'complaintsResolved': complaintsResolved,
    };
  }

  // Keep backward compatibility
  String? get profileImage => photoUrl;
}

// Type alias for backward compatibility
typedef User = UserModel;
