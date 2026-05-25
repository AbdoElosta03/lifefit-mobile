import 'package:flutter/material.dart';

import '../app_colors.dart';

/// FitLifeAuthBackground — soft teal corner waves (login / splash).
class FitLifeAuthBackground extends StatelessWidget {
  final Widget child;

  const FitLifeAuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.white),
        const Positioned(
          right: -40,
          top: -30,
          width: 220,
          height: 180,
          child: CustomPaint(painter: _TopWavePainter()),
        ),
        const Positioned(
          left: -60,
          bottom: -50,
          width: 280,
          height: 200,
          child: CustomPaint(painter: _BottomWavePainter()),
        ),
        child,
      ],
    );
  }
}

class _TopWavePainter extends CustomPainter {
  const _TopWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          AppColors.primaryLight.withValues(alpha: 0.45),
          AppColors.primary.withValues(alpha: 0.18),
        ],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.15,
        size.width,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.95,
        size.width * 0.05,
        size.height * 0.75,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomWavePainter extends CustomPainter {
  const _BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.22),
          AppColors.primaryLight.withValues(alpha: 0.08),
        ],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.05,
        size.width * 0.75,
        size.height * 0.25,
      )
      ..quadraticBezierTo(
        size.width,
        size.height * 0.55,
        size.width * 0.9,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
