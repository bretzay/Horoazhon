import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static const BoxShadow sm = BoxShadow(
    offset: Offset(0, 2),
    blurRadius: 8,
    color: AppColors.shadowColor,
  );

  static const BoxShadow md = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 16,
    color: AppColors.shadowColor,
  );

  static const BoxShadow lg = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 32,
    color: AppColors.shadowHeavy,
  );

  static List<BoxShadow> focusRing = const [
    BoxShadow(
      offset: Offset.zero,
      blurRadius: 0,
      spreadRadius: 3,
      color: AppColors.blueRing,
    ),
  ];

  static const List<BoxShadow> smList = [sm];
  static const List<BoxShadow> mdList = [md];
  static const List<BoxShadow> lgList = [lg];
}
