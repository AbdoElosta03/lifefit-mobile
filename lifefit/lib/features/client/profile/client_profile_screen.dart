import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إكمال الملف الشخصي'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'بيانات أساسية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // طول
            const TextField(
              decoration: InputDecoration(
                labelText: 'الطول (سم)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // الوزن
            const TextField(
              decoration: InputDecoration(
                labelText: 'الوزن الحالي (كجم)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // الهدف
            const TextField(
              decoration: InputDecoration(
                labelText: 'الهدف (إنقاص وزن / زيادة عضل...)',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                // هنا نكمل حفظ البيانات وربط API لاحقًا
              },
              child: const Text('حفظ والمتابعة'),
            ),
          ],
        ),
      ),
    );
  }
}
