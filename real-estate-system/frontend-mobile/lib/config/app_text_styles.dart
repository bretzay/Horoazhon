import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle textXl = TextStyle(
    fontSize: 24,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.slate900,
  );

  static const TextStyle textLg = TextStyle(
    fontSize: 18,
    letterSpacing: -0.25,
    height: 1.3,
    color: AppColors.slate900,
  );

  static const TextStyle textMd = TextStyle(
    fontSize: 14,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.slate700,
  );

  static const TextStyle textSm = TextStyle(
    fontSize: 12,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.slate500,
  );
}

extension TextStyleX on TextStyle {
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);

  TextStyle withColor(Color c) => copyWith(color: c);
}

class AppTextComposed {
  AppTextComposed._();

  static final TextStyle heroTitle     = AppTextStyles.textXl.w800;
  static final TextStyle statNumber    = AppTextStyles.textXl.w700;
  static final TextStyle pageHeading   = AppTextStyles.textLg.w700;
  static final TextStyle sectionHeading = AppTextStyles.textLg.w600;
  static final TextStyle cardTitle     = AppTextStyles.textMd.w600;
  static final TextStyle body          = AppTextStyles.textMd.w400;
  static final TextStyle label         = AppTextStyles.textMd.w500;
  static final TextStyle button        = AppTextStyles.textMd.w500;
  static final TextStyle navLink       = AppTextStyles.textMd.w500;
  static final TextStyle badge         = AppTextStyles.textSm.w600;
  static final TextStyle tableHeader   = AppTextStyles.textSm.w600;
  static final TextStyle caption       = AppTextStyles.textSm.w400;
}
