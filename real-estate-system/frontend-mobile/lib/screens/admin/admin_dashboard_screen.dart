import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../config/app_spacing.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dashboard_outlined, size: 48, color: AppColors.slate400),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Tableau de bord',
              style: AppTextStyles.textLg.w700.withColor(AppColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}
