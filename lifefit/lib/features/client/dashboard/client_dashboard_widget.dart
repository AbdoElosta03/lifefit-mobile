import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientDashboardWidget extends ConsumerWidget {
  const ClientDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryTeal = Color(0xFF00D9D9);
    const softBlue = Color(0xFF3ABEF9);
    const darkSlate = Color(0xFF1E293B);

    const formattedDate = "السبت، 20 أبريل - 15:30";

    const workoutProgress = _StatInfo(label: '4 / 6', progress: 0.67);
    const caloriesInfo = _StatInfo(label: '850 سعرة', progress: 0.58);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 700));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'مرحبًا يا بطل!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      formattedDate,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildStaticStatsRow(
                  workoutStats: workoutProgress,
                  nutritionStats: caloriesInfo,
                ),

                const SizedBox(height: 20),

                _buildMainActionCard(
                  title: 'تمرين الجزء العلوي',
                  subtitle: 'التمرين القادم: Bench Press',
                  buttonText: 'استكمال التمرين',
                  icon: Icons.fitness_center,
                  colors: [primaryTeal, const Color(0xFF00B4B4)],
                  onPressed: () {
                    _showStaticMessage(context, 'واجهة ثابتة فقط');
                  },
                ),

                const SizedBox(height: 16),

                _buildMainActionCard(
                  title: 'وجبة الغداء',
                  subtitle: 'سجل وجبتك الآن للحفاظ على خطتك',
                  buttonText: 'تسجيل الوجبة',
                  icon: Icons.restaurant,
                  colors: [softBlue, const Color(0xFF3572EF)],
                  onPressed: () {
                    _showStaticMessage(context, 'واجهة ثابتة فقط');
                  },
                ),

                const SizedBox(height: 16),

                _buildMainActionCard(
                  title: 'صور التقدم',
                  subtitle: 'آخر تحديث كان قبل يومين',
                  buttonText: 'عرض الصور',
                  icon: Icons.photo_library_outlined,
                  colors: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                  onPressed: () {
                    _showStaticMessage(context, 'واجهة ثابتة فقط');
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStaticMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _buildStaticStatsRow({
    required _StatInfo workoutStats,
    required _StatInfo nutritionStats,
  }) {
    return Column(
      children: [
        _buildCaloriesCard(nutritionStats),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: '82.0 كغ',
                subLabel: 'الوزن الحالي',
                value: 0.60,
                color: const Color(0xFF6366F1),
                icon: Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: workoutStats.label,
                subLabel: 'تمارين اليوم',
                value: workoutStats.progress,
                color: const Color(0xFF00D9D9),
                icon: Icons.bolt,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaloriesCard(_StatInfo stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D9D9), Color(0xFF00B4B4)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9D9).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 36,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'السعرات المتبقية',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: stats.progress,
              minHeight: 10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String subLabel,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: color.withOpacity(0.1),
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            subLabel,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.4), size: 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.first,
              minimumSize: const Size(double.infinity, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatInfo {
  final String label;
  final double progress;

  const _StatInfo({
    required this.label,
    required this.progress,
  });
}