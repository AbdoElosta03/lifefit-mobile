import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'personal_records_provider.dart';
import 'personal_record_tile.dart';

/// Full list of personal records from `GET /api/client/personal-records`.
class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(personalRecordsProvider);

    // Screen scaffold for the full personal records list.
    return Scaffold(
      backgroundColor: AppColors.background,
      // App bar: title + back action.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'الأرقام القياسية',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // Back button.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Body content by provider state.
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        // Error state with retry.
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 12),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // Retry button.
                TextButton(
                  onPressed: () =>
                      ref.read(personalRecordsProvider.notifier).refresh(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            // Empty state.
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'لا توجد أرقام قياسية بعد.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // Pull-to-refresh list.
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                ref.read(personalRecordsProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: list.length,
              itemBuilder: (context, i) {
                // Record card tile.
                return PersonalRecordTile(record: list[i], compact: false);
              },
            ),
          );
        },
      ),
    );
  }
}
