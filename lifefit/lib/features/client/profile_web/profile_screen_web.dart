import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile_web/client_profile_bundle.dart';
import '../../../core/models/profile_web/current_body_stats.dart';
import 'profile_edit_sheet_web.dart';
import 'profile_labels.dart';
import 'profile_provider_web.dart';

/// Profile screen backed by `GET/PUT /api/client/profile`.
class ProfileScreenWeb extends ConsumerWidget {
  const ProfileScreenWeb({super.key});

  static const _accent = Color(0xFF00D9D9);
  static const _dark = Color(0xFF0E5E68);
  static const _bg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientProfileWebProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _accent)),
        error: (e, _) => _ErrorPane(
          message: e.toString(),
          onRetry: () => ref.read(clientProfileWebProvider.notifier).refresh(),
        ),
        data: (bundle) => _ProfileBody(
          bundle: bundle,
          onEdit: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => ProfileEditSheetWeb(initial: bundle),
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ClientProfileBundle bundle;
  final VoidCallback onEdit;

  const _ProfileBody({required this.bundle, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final u = bundle.user;
    final p = bundle.profile;
    final s = bundle.currentStats;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 56,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0E5E68), Color(0xFF3D4260)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
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
                    _Avatar(url: u.avatarUrl),
                    const SizedBox(height: 12),
                    Text(
                      u.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
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
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _StatsCard(stats: s),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'البيانات الشخصية',
                children: [
                  _row(Icons.height, 'الطول', '${displayOrDash(p.heightCm)} سم'),
                  _row(Icons.flag_outlined, 'الهدف',
                      '${displayOrDash(p.targetWeightKg)} كجم'),
                  _row(Icons.cake_outlined, 'تاريخ الميلاد',
                      displayOrDash(p.birthDate)),
                  _row(Icons.wc_outlined, 'الجنس', translateGender(p.gender)),
                  _row(Icons.directions_run, 'النشاط',
                      translateActivityLevel(p.currentActivityLevel)),
                ],
              ),
              if (p.goalNotes != null && p.goalNotes!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                _NotesCard(text: p.goalNotes!),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  label: const Text('تعديل البيانات',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProfileScreenWeb._accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String title, String value) {
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
            child: Icon(icon, color: ProfileScreenWeb._accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ProfileScreenWeb._accent, width: 2.5),
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: const Color(0xFF3D4260),
        backgroundImage: u != null && u.isNotEmpty ? NetworkImage(u) : null,
        child: u == null || u.isEmpty
            ? const Icon(Icons.person_rounded,
                size: 52, color: ProfileScreenWeb._accent)
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
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Container(
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
            const Text(
              'القياسات الحالية',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: ProfileScreenWeb._dark,
              ),
            ),
            const SizedBox(height: 12),
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
            if (stats.recordedAt != null &&
                stats.recordedAt.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'آخر تحديث: ${stats.recordedAt}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _mini(IconData i, String l, String v, String unit) {
    return Expanded(
      child: Column(
        children: [
          Icon(i, color: ProfileScreenWeb._accent, size: 22),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: ProfileScreenWeb._dark,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D9D9).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('ملاحظات الأهداف',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.grey[800], height: 1.4)),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
