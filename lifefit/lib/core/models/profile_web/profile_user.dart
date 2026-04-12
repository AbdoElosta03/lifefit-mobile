class ProfileUser {
  final String name;
  final String email;
  final String? avatar;
  final String? avatarUrl;

  const ProfileUser({
    required this.name,
    required this.email,
    this.avatar,
    this.avatarUrl,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatar: json['avatar']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
