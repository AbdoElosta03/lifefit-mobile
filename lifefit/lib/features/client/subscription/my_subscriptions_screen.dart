import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/subscription/my_subscription_model.dart';
import 'subscription_provider.dart';

class MySubscriptionsScreen extends ConsumerWidget {
  const MySubscriptionsScreen({super.key});

  /// Main screen showing the list of active or past subscriptions for the client.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mySubscriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => _ErrorView(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(mySubscriptionsProvider),
        ),
        data: (subs) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            // ── Header Section ───────────────────────────────────────────
            // Contains page title and back navigation.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 20, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ]),
                    const Text('اشتراكاتي',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('${subs.length} اشتراك متاح',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── List or empty state ───────────────────────────────
            // Displays a list of subscription cards or a placeholder if empty.
            if (subs.isEmpty)
              const SliverToBoxAdapter(child: _EmptyView())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SubscriptionCard(sub: subs[i]),
                    childCount: subs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Subscription Card ────────────────────────────────────────────────────────
// Represents a single subscription entry with its status, type, and price.
class _SubscriptionCard extends StatelessWidget {
  final MySubscription sub;
  const _SubscriptionCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final service = sub.service;
    final statusColor = _statusColor(sub.status);
    final statusLabel = _statusLabel(sub.status);
    final typeColor = _typeColor(service?.type);
    final typeLabel = _typeLabel(service?.type);
    final renewalStr = sub.renewalDate != null
        ? DateFormat.yMMMd('ar').format(sub.renewalDate!)
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Visual accent bar colored by status (Active/Expired/etc)
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.3)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Service Title & Status Badge ────────────────
                Row(
                  children: [
                    _statusBadge(statusLabel, statusColor),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        service?.title ?? '—',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),

                // ── Expert Name ─────────────────────────────────
                if (service?.expertName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(service!.expertName!,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.person_outline,
                          size: 15, color: Colors.grey[500]),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                const SizedBox(height: 12),

                // ── Metadata Chips: Date, Type, and Price ──────────
                Row(
                  children: [
                    _dateChip(Icons.calendar_today_outlined, renewalStr),
                    const Spacer(),
                    if (service != null) ...[
                      _labelChip(typeLabel, typeColor),
                      const SizedBox(width: 8),
                      _labelChip(
                          '${service.price.toStringAsFixed(0)} ر.س',
                          AppColors.primary),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small chip indicating the subscription status (e.g., Active).
  static Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(width: 5),
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle)),
        ],
      ),
    );
  }

  /// Horizontal chip for date information.
  static Widget _dateChip(IconData icon, String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
        ],
      ),
    );
  }

  /// Generic label chip for types and prices.
  static Widget _labelChip(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }

  /// Maps subscription status string to branding colors.
  static Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'active':
        return AppColors.primary;
      case 'expired':
        return const Color(0xFFEF4444);
      case 'cancelled':
      case 'canceled':
        return Colors.grey;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  /// Translates status string to Arabic display labels.
  static String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'expired':
        return 'منتهي';
      case 'cancelled':
      case 'canceled':
        return 'ملغى';
      default:
        return s;
    }
  }

  static Color _typeColor(String? t) {
    switch (t) {
      case 'monthly':
        return const Color(0xFF3ABEF9);
      case 'quarterly':
        return const Color(0xFF8B5CF6);
      case 'yearly':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  static String _typeLabel(String? t) {
    switch (t) {
      case 'monthly':
        return 'شهري';
      case 'quarterly':
        return 'ربع سنوي';
      case 'yearly':
        return 'سنوي';
      default:
        return t ?? '—';
    }
  }
}

// ─── States ───────────────────────────────────────────────────────────────────

/// Placeholder view when no subscriptions are available.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_membership_outlined,
                size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('لا توجد اشتراكات',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
            'لم تشترك في أي خدمة بعد.\nتصفّح المتخصصين وابدأ رحلتك.',
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Generic error view for failed data loading.
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('تعذّر التحميل',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(message,
                style:
                    const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
  
