// lib/core/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // Can be 'user' or 'farmer'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  /// Creates a copy of the user model with updated fields.
  /// This is very useful for the 'Edit Profile' screen.
  UserModel copyWith({
    String? name,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: this.email,
      role: this.role,
    );
  }
}

