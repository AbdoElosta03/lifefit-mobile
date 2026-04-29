import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/notifications/app_notification.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_sound.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationsState {
  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  final bool loading;
  final bool loadingMore;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  bool get hasMore => currentPage < lastPage;

  NotificationsState copyWith({
    List<AppNotification>? items,
    int? currentPage,
    int? lastPage,
    bool? loading,
    bool? loadingMore,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._service) : super(const NotificationsState()) {
    refresh(isInitial: true);
  }

  final NotificationService _service;
  int _baselineMaxId = 0;
  bool _pollSoundEnabled = false;

  int _maxId(List<AppNotification> list) {
    if (list.isEmpty) return _baselineMaxId;
    return list.map((n) => n.id).reduce((a, b) => a > b ? a : b);
  }

  Future<void> refresh({bool isInitial = false, bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(loading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }
    try {
      final page = await _service.fetchPage(page: 1);
      _baselineMaxId = _maxId(page.data);
      if (isInitial) {
        _pollSoundEnabled = true;
      }
      state = state.copyWith(
        items: page.data,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> pollForNewNotifications() async {
    if (!_pollSoundEnabled) return;
    try {
      final page = await _service.fetchPage(page: 1);
      final hasNewUnread = page.data.any(
        (n) => !n.isRead && n.id > _baselineMaxId,
      );
      if (hasNewUnread) {
        await NotificationSound.play();
        await refresh(silent: true);
      } else {
        _baselineMaxId = _maxId(page.data);
      }
    } catch (_) {}
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.loading) return;
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final next = await _service.fetchPage(page: state.currentPage + 1);
      final seen = state.items.map((n) => n.id).toSet();
      final extra = next.data.where((n) => !seen.contains(n.id)).toList();
      state = state.copyWith(
        items: [...state.items, ...extra],
        currentPage: next.currentPage,
        lastPage: next.lastPage,
        loadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        loadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markOneRead(int id) async {
    try {
      await _service.markAsRead(id);
      state = state.copyWith(
        items: state.items
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllRead() async {
    try {
      await _service.markAllRead();
      state = state.copyWith(
        items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.watch(notificationServiceProvider));
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final s = ref.watch(notificationsProvider);
  return s.items.where((n) => !n.isRead).length;
});

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadNotificationCountProvider) > 0;
});
