// ─── Nested service info ──────────────────────────────────────────────────────

/// Nested `service` object inside a client subscription record.
class SubscriptionServiceInfo {
  final int id;
  final String title;

  /// 'monthly' | 'quarterly' | 'yearly'
  final String type;

  final double price;
  final String? expertName;

  const SubscriptionServiceInfo({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    this.expertName,
  });

  factory SubscriptionServiceInfo.fromJson(Map<String, dynamic> json) =>
      SubscriptionServiceInfo(
        id: json['id'] as int,
        title: json['title'] as String,
        type: json['type'] as String,
        price: (json['price'] as num).toDouble(),
        expertName: json['expert_name'] as String?,
      );
}

// ─── MySubscription ───────────────────────────────────────────────────────────
// Maps the payload returned by GET /api/client/my-subscriptions

class MySubscription {
  final int id;

  /// 'active' | 'expired' | 'cancelled'
  final String status;

  final DateTime? renewalDate;
  final SubscriptionServiceInfo? service;

  const MySubscription({
    required this.id,
    required this.status,
    this.renewalDate,
    this.service,
  });

  factory MySubscription.fromJson(Map<String, dynamic> json) => MySubscription(
        id: json['id'] as int,
        status: json['status'] as String,
        renewalDate: json['renewal_date'] != null
            ? DateTime.tryParse(json['renewal_date'] as String)
            : null,
        service: json['service'] != null
            ? SubscriptionServiceInfo.fromJson(
                json['service'] as Map<String, dynamic>)
            : null,
      );
}
