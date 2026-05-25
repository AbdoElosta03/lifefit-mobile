import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'fitlife_logo.dart';
import 'fitlife_wave_background.dart';

/// FitLifeBootSplash — splash while session restores (matches brand mockup).
class FitLifeBootSplash extends StatelessWidget {
  const FitLifeBootSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FitLifeAuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Widget: Brand logo + app name (same as login)
              const FitLifeLogo(
                height: 170,
                clipToMark: true,
                showWordmark: true,
              ),
              const Spacer(flex: 2),
              // Widget: Loading ring
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل البيانات...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
