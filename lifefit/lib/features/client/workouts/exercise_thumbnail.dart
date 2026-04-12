import 'package:flutter/material.dart';

/// Compact thumbnail for exercise list rows — image only, no video.
class ExerciseThumbnail extends StatelessWidget {
  final String? imageUrl;
  final bool dimmed;
  final double size;

  const ExerciseThumbnail({
    super.key,
    required this.imageUrl,
    this.dimmed = false,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null && url.isNotEmpty)
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: Color(0xFFF0F0F0),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00D9D9),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            else
              _placeholder(),
            if (dimmed)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Icon(Icons.done_all, color: Colors.white, size: 26),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => ColoredBox(
        color: const Color(0xFFF0F0F0),
        child: Icon(Icons.fitness_center, color: Colors.grey[500], size: 28),
      );
}
