// Model for a single service (monthly / quarterly / yearly) offered by an expert.
class ExpertServiceItem {
  final int id;
  final String title;
  final double price;
  final int maxParticipants;
  final int currentParticipants;

  const ExpertServiceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.maxParticipants,
    required this.currentParticipants,
  });

  factory ExpertServiceItem.fromJson(Map<String, dynamic> json) =>
      ExpertServiceItem(
        id: json['id'] as int,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        maxParticipants: json['max_participants'] as int? ?? 0,
        currentParticipants: json['current_participants'] as int? ?? 0,
      );
}

// ─── ExpertModel ─────────────────────────────────────────────────────────────
// Maps the payload returned by GET /api/client/available-experts

class ExpertModel {
  final int id;
  final String name;
  final String email;

  /// 'trainer' | 'nutritionist'
  final String role;

  final String? avatarUrl;
  final String? bio;
  final List<String> specialties;
  final int yearsExperience;

  /// True when the authenticated client has an active subscription to this expert.
  final bool isSubscribed;

  /// Keyed by service_type: 'monthly', 'quarterly', 'yearly'.
  final Map<String, ExpertServiceItem> services;

  const ExpertModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.bio,
    required this.specialties,
    required this.yearsExperience,
    required this.isSubscribed,
    required this.services,
  });

  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    // API may return `[]` (empty list) when no services exist — guard against it.
    final raw = json['services'];
    final Map<String, ExpertServiceItem> services;
    if (raw is Map<String, dynamic> && raw.isNotEmpty) {
      services = raw.map(
        (key, value) => MapEntry(
          key,
          ExpertServiceItem.fromJson(value as Map<String, dynamic>),
        ),
      );
    } else {
      services = {};
    }

    return ExpertModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [],
      yearsExperience: json['years_experience'] as int? ?? 0,
      isSubscribed: json['is_subscribed'] as bool? ?? false,
      services: services,
    );
  }

  /// Cheapest price across all available services. Null if no services.
  double? get lowestPrice {
    if (services.isEmpty) return null;
    return services.values.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }
}
