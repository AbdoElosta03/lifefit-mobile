import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subscriptions_provider.dart'; // تأكد من المسار الصحيح
import '../../../core/models/subscription.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(SubscriptionsProvider.provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'سجل الاشتراكات',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: subscriptions.isEmpty
          ? const Center(child: Text('لا توجد اشتراكات'))
          : RefreshIndicator(
              onRefresh: () async => await ref
                  .read(SubscriptionsProvider.provider.notifier)
                  .fetchSubscriptions(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subscriptions.length, // الطول الحقيقي للمصفوفة
                itemBuilder: (context, index) {
                  final subscription = subscriptions[index];
                  return _buildSubscriptionCard(context, subscription, ref);
                },
              ),
            ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    Subscription sub,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        onTap: () => _showSubscriptionDetails(
          context,
          sub,
          ref,
        ), // تمرير كائن الاشتراك للتفاصيل
        title: Text(
          sub.coachName, // الاسم الحقيقي من السيرفر
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 5),
            Text('الخدمة: ${sub.serviceTitle}', textAlign: TextAlign.right),
            Text('المدة: ${sub.duration}', textAlign: TextAlign.right),
          ],
        ),
        leading: Text(
          '${sub.price} د.ل', // السعر الحقيقي
          style: const TextStyle(
            color: Color(0xFF00D9D9),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showSubscriptionDetails(
    BuildContext context,
    Subscription sub,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(25.0),
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
              const SizedBox(height: 20),
              const Text(
                'تفاصيل الاشتراك الكاملة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDetailRow('اسم المدرب', sub.coachName),
                      _buildDetailRow('نوع الخدمة', sub.serviceTitle),
                      _buildDetailRow('مدة الاشتراك', sub.duration),
                      _buildDetailRow('السعر الإجمالي', '${sub.price} د.ل'),
                      _buildDetailRow('الحالة', sub.status, isStatus: true),
                      _buildDetailRow(
                        'تاريخ البداية',
                        sub.startDate.toString().split(' ')[0],
                      ),
                      _buildDetailRow(
                        'تاريخ النهاية',
                        sub.endDate.toString().split(' ')[0],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // أزرار التحكم...
              // أزرار التحكم
              Column(
                children: [
                  // زر إلغاء الاشتراك (يظهر فقط إذا كان الاشتراك نشطاً)
                  if (sub.status.toLowerCase() == 'active')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            // منطق إلغاء الاشتراك مع معالجة الأخطاء وإعلام المستخدم
                            try {
                              await ref
                                  .read(SubscriptionsProvider.provider.notifier)
                                  .cancelSubscription(sub.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إلغاء الاشتراك بنجاح'),
                                ),
                              );
                              Navigator.pop(
                                context,
                              ); // إغلاق النافذة بعد الإلغاء الناجح
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل إلغاء الاشتراك: $error'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'إلغاء الاشتراك',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'رجوع',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isStatus
                  ? (value == 'active' ? Colors.green : Colors.red)
                  : Colors.black87,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
