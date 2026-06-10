import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/auth/auth_provider.dart';
import '../../../core/models/profile_web/client_profile_bundle.dart';
import '../../../core/services/profile_web_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/widgets/fitlife_wave_background.dart';
import '../profile/profile_provider.dart';
import 'profile_onboarding_provider.dart';
import 'widgets/onboarding_widgets.dart';

/// Multi-step profile setup shown before [ClientHomeScreen] when data is missing.
class ProfileOnboardingScreen extends ConsumerStatefulWidget {
  final ClientProfileBundle? initialBundle;

  const ProfileOnboardingScreen({super.key, this.initialBundle});

  @override
  ConsumerState<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends ConsumerState<ProfileOnboardingScreen> {
  static const _stepLabels = [
    'مرحباً',
    'قياسات الجسم',
    'أهدافك',
    'ملخص',
  ];

  final _pageController = PageController();
  int _currentStep = 1;
  bool _saving = false;

  DateTime? _birthDate;
  double _heightCm = 170;
  double _weightKg = 70;
  double? _targetWeightKg;
  String? _selectedGoal;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seedFromBundle(widget.initialBundle);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _seedFromBundle(ClientProfileBundle? bundle) {
    if (bundle == null) return;
    final birth = bundle.profile.birthDate;
    if (birth != null && birth.isNotEmpty) {
      _birthDate = DateTime.tryParse(birth);
    }
    _heightCm = bundle.profile.heightCm ?? _heightCm;
    _weightKg = bundle.currentStats.weightKg ?? _weightKg;
    _targetWeightKg = bundle.profile.targetWeightKg;
    final notes = bundle.profile.goalNotes?.trim();
    if (notes != null && notes.isNotEmpty) {
      _selectedGoal = notes;
      _notesController.text = notes;
    }
  }

  String get _userName =>
      ref.read(authProvider).user?.name.split(' ').first ?? 'بك';

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep >= _stepLabels.length) {
      _finish();
      return;
    }
    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _prevStep() {
    if (_currentStep <= 1) return;
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        if (_birthDate == null) {
          _showError('يرجى اختيار تاريخ الميلاد');
          return false;
        }
        return true;
      case 2:
        if (_heightCm < 100 || _heightCm > 250) {
          _showError('يرجى إدخال طول صحيح');
          return false;
        }
        if (_weightKg < 30 || _weightKg > 300) {
          _showError('يرجى إدخال وزن صحيح');
          return false;
        }
        return true;
      case 3:
        if (_selectedGoal == null) {
          _showError('يرجى اختيار هدفك الرئيسي');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final profileService = ProfileService();
    final progressService = ProgressService();

    final birthStr = DateFormat('yyyy-MM-dd').format(_birthDate!);
    final goalNotes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : _selectedGoal!;

    try {
      final bundle = await profileService.updateProfile({
        'birth_date': birthStr,
        'height_cm': _heightCm,
        'weight_kg': _weightKg,
        'goal_notes': goalNotes,
      });

      if (_targetWeightKg != null) {
        await progressService.createOrReplaceGoal({
          'target_weight': _targetWeightKg,
          'start_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        });
      }

      ref.invalidate(clientProfileProvider);
      ref.read(profileGateProvider.notifier).markComplete(bundle);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FitLifeAuthBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: OnboardingStepIndicator(
                    currentStep: _currentStep,
                    totalSteps: _stepLabels.length,
                    labels: _stepLabels,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcomeStep(),
                      _buildBodyStep(),
                      _buildGoalsStep(),
                      _buildSummaryStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: OnboardingNavBar(
                    showBack: _currentStep > 1,
                    nextLabel: _currentStep == _stepLabels.length
                        ? 'ابدأ رحلتك'
                        : 'التالي',
                    isLoading: _saving,
                    onBack: _prevStep,
                    onNext: _nextStep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 12),
          OnboardingStepHeader(
            icon: Icons.waving_hand_rounded,
            title: 'مرحباً $_userName!',
            subtitle:
                'لنخصّص تجربتك في لايف فت. أخبرنا قليلاً عن نفسك لنبني برنامجاً يناسبك.',
          ),
          const SizedBox(height: 32),
          _DatePickerTile(
            label: 'تاريخ الميلاد',
            value: _birthDate == null
                ? 'اضغط للاختيار'
                : DateFormat('d MMMM yyyy', 'ar').format(_birthDate!),
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'بياناتك محمية ولن تُشارك إلا مع مدربك المعتمد.',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const OnboardingStepHeader(
            icon: Icons.straighten_rounded,
            title: 'قياسات الجسم',
            subtitle: 'ساعدنا على حساب مؤشراتك الصحية وتتبع تقدمك بدقة.',
          ),
          const SizedBox(height: 28),
          OnboardingNumberPicker(
            label: 'الطول',
            unit: 'سم',
            value: _heightCm,
            min: 120,
            max: 230,
            step: 1,
            onChanged: (v) => setState(() => _heightCm = v),
          ),
          const SizedBox(height: 16),
          OnboardingNumberPicker(
            label: 'الوزن الحالي',
            unit: 'كجم',
            value: _weightKg,
            min: 40,
            max: 200,
            step: 0.5,
            onChanged: (v) => setState(() => _weightKg = v),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    const goals = [
      (Icons.trending_down, 'إنقاص الوزن', 'حرق الدهون وتحسين اللياقة'),
      (Icons.fitness_center, 'بناء العضلات', 'زيادة القوة وكتلة العضل'),
      (Icons.directions_run, 'اللياقة العامة', 'تحسين الصحة والنشاط اليومي'),
      (Icons.self_improvement, 'المرونة', 'توازن الجسم والاسترخاء'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const OnboardingStepHeader(
            icon: Icons.flag_rounded,
            title: 'ما هو هدفك؟',
            subtitle: 'اختر الهدف الأقرب لك — يمكنك تعديله لاحقاً من الملف الشخصي.',
          ),
          const SizedBox(height: 24),
          ...goals.map((g) {
            final title = g.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OnboardingGoalCard(
                icon: g.$1,
                title: title,
                subtitle: g.$3,
                selected: _selectedGoal == title,
                onTap: () => setState(() {
                  _selectedGoal = title;
                  _notesController.text = title;
                }),
              ),
            );
          }),
          const SizedBox(height: 8),
          OnboardingNumberPicker(
            label: 'الوزن المستهدف (اختياري)',
            unit: 'كجم',
            value: _targetWeightKg ?? _weightKg,
            min: 40,
            max: 200,
            step: 0.5,
            onChanged: (v) => setState(() => _targetWeightKg = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    final bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    final age = _birthDate == null
        ? '—'
        : '${DateTime.now().year - _birthDate!.year} سنة';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const OnboardingStepHeader(
            icon: Icons.check_circle_outline,
            title: 'كل شيء جاهز!',
            subtitle: 'راجع بياناتك قبل الدخول إلى التطبيق.',
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _SummaryRow('العمر', age),
                _SummaryRow(
                  'الطول',
                  '${_heightCm.toStringAsFixed(_heightCm == _heightCm.roundToDouble() ? 0 : 1)} سم',
                ),
                _SummaryRow(
                  'الوزن',
                  '${_weightKg.toStringAsFixed(_weightKg == _weightKg.roundToDouble() ? 0 : 1)} كجم',
                ),
                if (_targetWeightKg != null)
                  _SummaryRow(
                    'الوزن المستهدف',
                    '${_targetWeightKg!.toStringAsFixed(_targetWeightKg! == _targetWeightKg!.roundToDouble() ? 0 : 1)} كجم',
                  ),
                _SummaryRow('الهدف', _selectedGoal ?? '—'),
                _SummaryRow('مؤشر BMI', bmi.toStringAsFixed(1)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primaryLight.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '🎉 أنت على بعد خطوة من بدء رحلتك! اضغط "ابدأ رحلتك" للدخول.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
