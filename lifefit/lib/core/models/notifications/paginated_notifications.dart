import 'app_notification.dart';

class PaginatedNotifications {
  final List<AppNotification> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginatedNotifications({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <AppNotification>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map) {
          list.add(AppNotification.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return PaginatedNotifications(
      data: list,
      currentPage: _int(json['current_page'], fallback: 1),
      lastPage: _int(json['last_page'], fallback: 1),
      perPage: _int(json['per_page'], fallback: 20),
      total: _int(json['total'], fallback: list.length),
    );
  }

  static int _int(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }
}
