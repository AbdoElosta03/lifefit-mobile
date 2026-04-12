import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'personal_records_provider.dart';
import 'personal_records_screen.dart';
import 'personal_record_tile.dart';

/// Preview (max 3) + "عرض الكل" on the Progress tab.
class PersonalRecordsPreviewSection extends ConsumerWidget {
  const PersonalRecordsPreviewSection({super.key});

  static const _primary = Color(0xFF00D9D9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(personalRecordsProvider);

    return async.when(
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
          ),
        ),
      ),
      error: (e, _) => _errorCard(e.toString()),
      data: (list) {
        if (list.isEmpty) {
          return _emptyCard();
        }
        final preview = list.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'أحدث الأرقام القياسية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PersonalRecordsScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...preview.map(
              (r) => PersonalRecordTile(record: r, compact: true),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'أحدث الأرقام القياسية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد أرقام قياسية بعد. سجّل تمارينك ليظهر تقدّمك هنا.',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.right,
        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
      ),
    );
  }
}
