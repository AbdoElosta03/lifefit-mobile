import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile_web/client_profile_bundle.dart';
import '../../../core/models/profile_web/current_body_stats.dart';
import '../progrees/goals_provider.dart';
import '../utilits/date_text.dart';
import 'profile_edit_sheet.dart';
import 'profile_labels.dart';
import 'profile_provider.dart';

/// Client profile — read-only view with edit entry point.
/// Data flow: clientProfileProvider + goalsProvider → _ProfileBody → ProfileEditSheet.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _accent = AppColors.primary;
  static const _dark = Color(0xFF0E5E68);
  static const _headerColor = AppColors.primaryDark;
  static const _bg = AppColors.background;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientProfileProvider);
    final goalsAsync = ref.watch(goalsProvider);
    // Target weight: prefer goals provider, fall back to profile field.
    final fallbackTarget = goalsAsync.maybeWhen(
      data: (g) => g.isNotEmpty ? g.first.targetWeight : null,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: _bg,
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _accent)),
        error: (e, _) => _ErrorPane(
          message: e.toString(),
          onRetry: () => ref.read(clientProfileProvider.notifier).refresh(),
        ),
        data: (bundle) => _ProfileBody(
          bundle: bundle,
          targetWeight: fallbackTarget,
          onEdit: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => ProfileEditSheet(initial: bundle),
          ),
        ),
      ),
    );
  }
}

/// Scrollable layout: header, stats, personal info, notes, edit card.
class _ProfileBody extends StatelessWidget {
  final ClientProfileBundle bundle;
  final double? targetWeight;
  final VoidCallback onEdit;

  const _ProfileBody({
    required this.bundle,
    required this.targetWeight,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final u = bundle.user;
    final p = bundle.profile;
    final s = bundle.currentStats;
    final target = targetWeight ?? p.targetWeightKg;

    // Scrollable profile layout.
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header block.
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: ProfileScreen._headerColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                // App bar row.
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        'ملفي الشخصي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),
                // Avatar widget.
                _Avatar(url: u.displayAvatarUrl),
                const SizedBox(height: 12),
                // User name.
                Text(
                  u.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                // User email.
                Text(
                  u.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                // Current stats card.
                _StatsCard(stats: s),
                const SizedBox(height: 14),
                // Personal data section.
                _SectionCard(
                  title: 'البيانات الشخصية',
                  children: [
                    _row(
                      Icons.height,
                      'الطول',
                      Text(
                        '${displayOrDash(p.heightCm)} سم',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _row(
                      Icons.flag_outlined,
                      'الهدف',
                      Text(
                        '${displayOrDash(target)} كجم',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _row(
                      Icons.cake_outlined,
                      'تاريخ الميلاد',
                      DateText(
                        value: p.birthDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _row(
                      Icons.wc_outlined,
                      'الجنس',
                      Text(
                        translateGender(p.gender),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (p.goalNotes != null && p.goalNotes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  // Notes card.
                  _NotesCard(text: p.goalNotes!),
                ],
                const SizedBox(height: 16),
                // Edit entry card.
                _EditEntryCard(onTap: onEdit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, Widget value) {
    // Profile row item.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBFF5F4).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ProfileScreen._accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Flexible(child: value),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    final u = url;
    // Avatar with border.
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ProfileScreen._accent, width: 2.5),
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: ProfileScreen._headerColor,
        backgroundImage: u != null && u.isNotEmpty ? NetworkImage(u) : null,
        child: u == null || u.isEmpty
            ? const Icon(Icons.person_rounded,
                size: 52, color: ProfileScreen._accent)
            : null,
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final CurrentBodyStats stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Current stats card.
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Section title.
          const Text(
            'القياسات الحالية',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: ProfileScreen._dark,
            ),
          ),
          const SizedBox(height: 12),
          // Metrics row.
          Row(
            children: [
              _mini(Icons.monitor_weight_outlined, 'الوزن',
                  displayOrDash(stats.weightKg), 'كجم'),
              _mini(Icons.percent, 'الدهون',
                  displayOrDash(stats.bodyFatPct), '%'),
              _mini(Icons.fitness_center, 'العضل',
                  displayOrDash(stats.muscleMassKg), 'كجم'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(IconData i, String l, String v, String unit) {
    // Single metric item.
    return Expanded(
      child: Column(
        children: [
          Icon(i, color: ProfileScreen._accent, size: 22),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(l, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    // Section card wrapper.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Section title.
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: ProfileScreen._dark,
            ),
          ),
          const Divider(height: 22),
          ...children,
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String text;
  const _NotesCard({required this.text});

  @override
  Widget build(BuildContext context) {
    // Notes card.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ProfileScreen._accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Notes title.
          const Text('ملاحظات الأهداف',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          // Notes body.
          Text(text, style: TextStyle(color: Colors.grey[800], height: 1.4)),
        ],
      ),
    );
  }
}

class _EditEntryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EditEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Edit entry card.
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.edit_rounded, color: ProfileScreen._accent, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'تعديل البيانات',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPane({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // Error panel with retry.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            // Error message.
            Text(message, textAlign: TextAlign.center),
            // Retry button.
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
