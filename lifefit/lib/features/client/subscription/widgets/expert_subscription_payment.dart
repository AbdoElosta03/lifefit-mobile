import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/subscription/expert_model.dart';
import '../../../../core/services/subscription_service.dart';
import '../payment_screen.dart';
import '../subscription_provider.dart';

/// Bottom sheet to pick an expert's service before Moamalat checkout.
class ExpertServiceSelectionSheet extends StatefulWidget {
  final ExpertModel expert;

  const ExpertServiceSelectionSheet({super.key, required this.expert});

  @override
  State<ExpertServiceSelectionSheet> createState() =>
      _ExpertServiceSelectionSheetState();
}

class _ExpertServiceSelectionSheetState
    extends State<ExpertServiceSelectionSheet> {
  ExpertServiceItem? _selected;

  /// Helper to map technical service types to readable Arabic labels.
  String _typeLabel(String type) {
    switch (type) {
      case 'monthly':
        return 'شهري';
      case 'quarterly':
        return 'ربع سنوي';
      case 'yearly':
        return 'سنوي';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.expert.services.entries.toList();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Drag handle for the bottom sheet
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'اختر خطة الاشتراك مع ${widget.expert.name}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          // List of available service plans (Monthly, Yearly, etc.)
          ...services.map((entry) {
            final item = entry.value;
            final isSelected = _selected?.id == item.id;
            return GestureDetector(
              onTap: () => setState(() => _selected = item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.07)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.title.isNotEmpty
                                ? item.title
                                : _typeLabel(entry.key),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _typeLabel(entry.key),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.price.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          // Button to proceed to the secure payment gateway
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
              child: const Text(
                'المتابعة للدفع',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Orchestrator class for the subscription payment flow.
/// 
/// Sequence:
/// 1. [Select Plan] via BottomSheet.
/// 2. [Initiate Payment] via Backend API to get Moamalat params.
/// 3. [Open Gateway] via WebView with the retrieved params.
/// 4. [Verify & Result] Handle success/fail/cancel callbacks.
class ExpertSubscriptionPayment {
  ExpertSubscriptionPayment._();

  static Future<void> start(
    BuildContext context,
    WidgetRef ref, {
    required ExpertModel expert,
  }) async {
    // Step 1: User picks a specific service plan
    final selectedService = await showModalBottomSheet<ExpertServiceItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpertServiceSelectionSheet(expert: expert),
    );
    if (selectedService == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تحضير بيانات الدفع...')),
    );

    try {
      // Step 2: Request Moamalat secure parameters from the backend
      final data =
          await SubscriptionService().initiatePayment(selectedService.id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Step 3: Launch the Moamalat payment WebView
      final result = await MoamalatPaymentScreen.open(context, data);

      if (!context.mounted) return;
      
      // Step 4: Handle the terminal payment result
      if (result == PaymentResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الاشتراك بنجاح! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh experts list to show 'Subscribed' status
        ref.read(expertsProvider.notifier).refresh();
      } else if (result == PaymentResult.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء عملية الدفع.')),
        );
      } else if (result == PaymentResult.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشلت عملية الدفع. حاول مرة أخرى.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }
}
