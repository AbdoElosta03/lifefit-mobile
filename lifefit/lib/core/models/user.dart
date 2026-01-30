class User {
  final int id;
  final String email;
  final String name;
  final String role;

  final String? phone;
  final String? avatar;
  final String? bio;

  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.avatar,
    this.bio,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],

      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],

      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }
}
