/// Account fields returned inside the profile bundle (subset of [User]).
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

  String? get displayAvatarUrl {
    final url = _normalizeAvatarUrl(avatarUrl);
    if (url != null) return url;
    return _normalizeAvatarUrl(avatar);
  }

  static String? _normalizeAvatarUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    
    // Find the last occurrence of http:// or https:// 
    
    final embeddedHttpIndex = raw.lastIndexOf('http://');
    final embeddedHttpsIndex = raw.lastIndexOf('https://');
    final embeddedIndex = embeddedHttpsIndex > embeddedHttpIndex
        ? embeddedHttpsIndex
        : embeddedHttpIndex;

    if (embeddedIndex > 0) {
      return raw.substring(embeddedIndex);
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    return null;
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatar: json['avatar']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
