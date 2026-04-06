import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // ─── Design Tokens ───────────────────────────────────────────
  static const Color kAccent = Color(0xFF00D9D9);
  static const Color kDark = Color(0xFF0E5E68);
  static const Color kBackground = Color(0xFFF8F9FA);
  static const Color kWhite = Colors.white;
  static const Color kSubtext = Color(0xFF9098A3);
  static const Color kAccentSoft = Color(0xFFBFF5F4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(ProfileProvider.provider);

    return Scaffold(
      backgroundColor: kBackground,
      body: profileState.when(
        data: (profile) => _buildBody(context, ref, profile),
        loading: () => const Center(
          child: CircularProgressIndicator(color: kAccent, strokeWidth: 3),
        ),
        error: (e, st) => _buildError(e),
      ),
    );
  }

  // ─── Error State ─────────────────────────────────────────────
  Widget _buildError(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "حدث خطأ في تحميل البيانات",
              style: TextStyle(
                color: kDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main Body ───────────────────────────────────────────────
  Widget _buildBody(BuildContext context, WidgetRef ref, Profile profile) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, profile)),
        SliverToBoxAdapter(child: _buildQuickStats(profile)),
        SliverToBoxAdapter(child: _buildInfoCard(profile)),
        SliverToBoxAdapter(child: _buildEditButton(context, ref, profile)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // ─── Curved Header ───────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Profile profile) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 60,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kDark, Color(0xFF3D4260)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _headerIcon(
                      Icons.arrow_back_ios_new_rounded,
                      () => Navigator.of(context).maybePop(),
                    ),
                    const Text(
                      "ملفي الشخصي",
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildAvatar(),
              const SizedBox(height: 14),
              const Text(
                "المستخدم",
                style: TextStyle(
                  color: kWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _buildActivityBadge(profile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kAccent, width: 2.5),
        boxShadow: [
          BoxShadow(color: kAccent.withOpacity(0.25), blurRadius: 20),
        ],
      ),
      child: const CircleAvatar(
        radius: 46,
        backgroundColor: Color(0xFF3D4260),
        child: Icon(Icons.person_rounded, size: 50, color: kAccent),
      ),
    );
  }

  Widget _buildActivityBadge(Profile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: kAccentSoft.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: kAccent, size: 16),
          const SizedBox(width: 4),
          Text(
            _translateActivityLevel(profile.activityLevel),
            style: const TextStyle(
              color: kAccent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kWhite, size: 20),
      ),
    );
  }

  // ─── Quick Stats ─────────────────────────────────────────────
  Widget _buildQuickStats(Profile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              icon: Icons.cake_outlined,
              value: "${profile.age ?? '--'}",
              unit: "سنة",
              label: "العمر",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickStatCard(
              icon: Icons.height_rounded,
              value: "${profile.heightCm ?? '--'}",
              unit: "سم",
              label: "الطول",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickStatCard(
              icon: Icons.flag_rounded,
              value: "${profile.targetWeightKg ?? '--'}",
              unit: "كجم",
              label: "الهدف",
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info Card ───────────────────────────────────────────────
  Widget _buildInfoCard(Profile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 14, right: 4),
            child: Text(
              "المعلومات الشخصية",
              style: TextStyle(
                color: kDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: kDark.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.cake_outlined,
                  title: "العمر",
                  value: "${profile.age ?? 'غير محدد'} سنة",
                ),
                _divider(),
                _InfoRow(
                  icon: Icons.straighten_rounded,
                  title: "الطول",
                  value: "${profile.heightCm ?? 'غير محدد'} سم",
                ),
                _divider(),
                _InfoRow(
                  icon: Icons.monitor_weight_outlined,
                  title: "الهدف",
                  value: "${profile.targetWeightKg ?? 'غير محدد'} كجم",
                ),
                _divider(),
                _InfoRow(
                  icon: Icons.directions_run_rounded,
                  title: "النشاط",
                  value: _translateActivityLevel(profile.activityLevel),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    indent: 62,
    endIndent: 20,
    color: kDark.withOpacity(0.06),
  );

  // ─── Edit Button (Trigger for Modal) ─────────────────────────
  Widget _buildEditButton(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => _showEditModal(context, ref, profile),
          icon: const Icon(Icons.edit_rounded, size: 20),
          label: const Text(
            "تعديل البيانات",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kWhite,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref, Profile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileModal(profile: profile),
    );
  }

  String _translateActivityLevel(String? level) {
    if (level == null || level.isEmpty) return 'غير محدد';
    switch (level.toLowerCase()) {
      case 'sedentary':
        return 'خامل';
      case 'low':
        return 'منخفض';
      case 'moderate':
        return 'متوسط';
      case 'active':
        return 'نشط';
      case 'athlete':
        return 'رياضي';
      default:
        return level;
    }
  }
}

// ─── Modal Implementation ──────────────────────────────────────
class _EditProfileModal extends ConsumerStatefulWidget {
  final Profile profile;
  const _EditProfileModal({required this.profile});

  @override
  ConsumerState<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<_EditProfileModal> {
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _notesCtrl;
  String? _activityLevel;
  bool _isSaving = false;

  static const List<Map<String, String>> _activityOptions = [
    {'value': 'sedentary', 'label': 'خامل'},
    {'value': 'low', 'label': 'منخفض'},
    {'value': 'moderate', 'label': 'متوسط'},
    {'value': 'active', 'label': 'نشط'},
    {'value': 'athlete', 'label': 'رياضي'},
  ];

  @override
  void initState() {
    super.initState();
    _ageCtrl = TextEditingController(text: widget.profile.age?.toString());
    _heightCtrl = TextEditingController(
      text: widget.profile.heightCm?.toString(),
    );
    _weightCtrl = TextEditingController(
      text: widget.profile.targetWeightKg?.toString(),
    );
    _notesCtrl = TextEditingController(text: widget.profile.goalNotes);
    _activityLevel = widget.profile.activityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "تحديث بياناتك",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ProfileScreen.kDark,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField("العمر", _ageCtrl, Icons.cake_rounded),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "الطول",
                  _heightCtrl,
                  Icons.height_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "الوزن المستهدف",
            _weightCtrl,
            Icons.track_changes_rounded,
          ),
          const SizedBox(height: 16),
          _buildActivityDropdown(),
          const SizedBox(height: 16),
          _buildTextField(
            "ملاحظات الأهداف",
            _notesCtrl,
            Icons.notes_rounded,
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileScreen.kAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "حفظ التغييرات",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ProfileScreen.kSubtext,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: ProfileScreen.kAccent, size: 20),
            filled: true,
            fillColor: ProfileScreen.kBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "مستوى النشاط",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ProfileScreen.kSubtext,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _activityLevel,
          items: _activityOptions
              .map(
                (opt) => DropdownMenuItem<String>(
                  value: opt['value'],
                  child: Text(opt['label'] ?? ''),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _activityLevel = value);
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.directions_run_rounded,
              color: ProfileScreen.kAccent,
              size: 20,
            ),
            filled: true,
            fillColor: ProfileScreen.kBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final updatedProfile = Profile(
      age: int.tryParse(_ageCtrl.text),
      heightCm: double.tryParse(_heightCtrl.text),
      targetWeightKg: double.tryParse(_weightCtrl.text),
      goalNotes: _notesCtrl.text,
      activityLevel: _activityLevel ?? widget.profile.activityLevel,
    );

    try {
      await ref
          .read(ProfileProvider.provider.notifier)
          .saveProfile(updatedProfile);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context); // إغلاق المودال
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم التحديث بنجاح"),
            backgroundColor: ProfileScreen.kAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ProfileScreen.kDark.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ProfileScreen.kAccentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: ProfileScreen.kAccent, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: ProfileScreen.kDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(color: ProfileScreen.kSubtext, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: ProfileScreen.kDark.withOpacity(0.55),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: ProfileScreen.kAccentSoft.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ProfileScreen.kAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: ProfileScreen.kDark.withOpacity(0.55),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ProfileScreen.kDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_left_rounded,
            color: ProfileScreen.kDark.withOpacity(0.2),
            size: 20,
          ),
        ],
      ),
    );
  }
}
