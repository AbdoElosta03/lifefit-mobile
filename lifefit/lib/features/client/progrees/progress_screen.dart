import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // الخلفية الموحدة للتطبيق
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // العنوان
            const Text('التقدم', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            const Text('تتبع إنجازاتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 25),

            // 1. كارد الوزن الملون (لأنه التحدي الأكبر)
            _buildMainWeightCard(),

            const SizedBox(height: 20),

            
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  // ويدجت كارد الوزن الأساسي (الملون)
  Widget _buildMainWeightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9D9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: const Color(0xFF00D9D9).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('الوزن الحالي', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const Text('82.5 كغ', style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: 0.7, minHeight: 7, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation(Colors.white)),
          ),
          const SizedBox(height: 10),
          const Text('الهدف: 78 كغ', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  
}

// ويدجت صف الأرقام القياسية المختصرة
class _RecordRow extends StatelessWidget {
  final String label, value, sub;
  const _RecordRow({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(sub, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
        Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
\\\\\\\