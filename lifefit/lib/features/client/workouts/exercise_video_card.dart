import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [videoUrl] in the browser / external player — no autoplay in-app.
class ExerciseVideoCard extends StatelessWidget {
  final String videoUrl;
  final Color primary;

  const ExerciseVideoCard({
    super.key,
    required this.videoUrl,
    this.primary = const Color(0xFF00D9D9),
  });

  Future<void> _open() async {
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_filled_rounded, color: primary, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'فيديو التمرين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _open,
              icon: Icon(Icons.open_in_new_rounded, size: 18, color: primary),
              label: Text(
                'مشاهدة الفيديو',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
