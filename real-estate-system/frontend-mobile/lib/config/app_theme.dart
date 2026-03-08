import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: AppColors.blue500,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.blue100,
        onPrimaryContainer: AppColors.blue600,
        secondary: AppColors.slate900,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.slate100,
        onSecondaryContainer: AppColors.slate900,
        surface: AppColors.white,
        onSurface: AppColors.slate700,
        surfaceContainerHighest: AppColors.slate50,
        error: AppColors.slate900,
        onError: AppColors.white,
        outline: AppColors.slate200,
        outlineVariant: AppColors.slate100,
      ),

      scaffoldBackgroundColor: AppColors.slate50,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.slate900,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadowColor,
        titleTextStyle: AppTextStyles.textLg.w700.copyWith(color: AppColors.slate900),
        iconTheme: const IconThemeData(color: AppColors.slate700, size: 24),
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.textXl.w700,
        headlineMedium: AppTextStyles.textLg.w700,
        headlineSmall: AppTextStyles.textLg.w600,
        titleLarge: AppTextStyles.textMd.w600,
        titleMedium: AppTextStyles.textMd.w500,
        bodyLarge: AppTextStyles.textMd.w400,
        bodyMedium: AppTextStyles.textMd.w400,
        bodySmall: AppTextStyles.textSm.w400,
        labelLarge: AppTextStyles.textMd.w500,
        labelMedium: AppTextStyles.textSm.w600,
        labelSmall: AppTextStyles.textSm.w400,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue500,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTextStyles.textMd.w500,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.slate700,
          side: const BorderSide(color: AppColors.slate200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTextStyles.textMd.w500,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue500,
          textStyle: AppTextStyles.textMd.w500,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space3,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.blue500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.blue500),
        ),
        hintStyle: AppTextStyles.textMd.w400.withColor(AppColors.slate400),
        labelStyle: AppTextStyles.textMd.w500.withColor(AppColors.slate700),
        errorStyle: AppTextStyles.textSm.w400.withColor(AppColors.slate900),
      ),

      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: const BorderSide(color: AppColors.slate200),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.slate200,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slate100,
        labelStyle: AppTextStyles.textSm.w600,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fullAll,
        ),
        side: BorderSide.none,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.blue500,
        unselectedItemColor: AppColors.slate400,
        selectedLabelStyle: AppTextStyles.textSm.w500,
        unselectedLabelStyle: AppTextStyles.textSm.w400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
        ),
        elevation: 0,
        titleTextStyle: AppTextStyles.textLg.w700.copyWith(color: AppColors.slate900),
        contentTextStyle: AppTextStyles.textMd.w400.copyWith(color: AppColors.slate700),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate900,
        contentTextStyle: AppTextStyles.textMd.w400.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.blue500,
        unselectedLabelColor: AppColors.slate500,
        indicatorColor: AppColors.blue500,
        labelStyle: AppTextStyles.textMd.w500,
        unselectedLabelStyle: AppTextStyles.textMd.w400,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blue500,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      visualDensity: VisualDensity.standard,
    );
  }
}
