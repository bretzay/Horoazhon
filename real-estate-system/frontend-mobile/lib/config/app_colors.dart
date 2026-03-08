import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- 16 palette tokens ---
  static const Color blue500    = Color(0xFF2563EB);
  static const Color blue600    = Color(0xFF1D4ED8);
  static const Color blue400    = Color(0xFF3B82F6);
  static const Color blue100    = Color(0xFFDBEAFE);
  static const Color blue50     = Color(0xFFEFF6FF);
  static const Color slate900   = Color(0xFF0F172A);
  static const Color slate700   = Color(0xFF334155);
  static const Color slate500   = Color(0xFF64748B);
  static const Color slate400   = Color(0xFF94A3B8);
  static const Color slate200   = Color(0xFFE2E8F0);
  static const Color slate100   = Color(0xFFF1F5F9);
  static const Color slate50    = Color(0xFFF8FAFC);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color blueRing   = Color(0x192563EB);
  static const Color shadowColor = Color(0x0F0F172A);
  static const Color shadowHeavy = Color(0x1A0F172A);

  // --- Semantic mapping ---
  static const Color defaultText   = slate700;
  static const Color defaultBg     = white;
  static const Color defaultBorder = slate200;

  static const Color successText   = blue600;
  static const Color successBg     = blue50;
  static const Color successBorder = blue400;

  static const Color errorText     = slate900;
  static const Color errorBg       = blue100;
  static const Color errorBorder   = blue500;

  static const Color warningText   = slate700;
  static const Color warningBg     = slate50;
  static const Color warningBorder = slate200;

  static const Color infoText      = blue500;
  static const Color infoBg        = blue50;
  static const Color infoBorder    = blue100;

  static const Color disabledText   = slate400;
  static const Color disabledBg     = slate50;
  static const Color disabledBorder = slate200;

  // --- Text color hierarchy ---
  static const Color textPrimary   = slate900;
  static const Color textSecondary = slate700;
  static const Color textTertiary  = slate500;
  static const Color textMuted     = slate400;
  static const Color textAccent    = blue500;

  // --- Badge colors ---
  static Color badgeBg(String type) => _badgeBg[type] ?? slate200;
  static Color badgeText(String type) => _badgeText[type] ?? slate700;

  static const Map<String, Color> _badgeBg = {
    'vente':    blue500,
    'location': slate900,
    'en_cours': blue100,
    'signe':    slate100,
    'annule':   slate200,
    'termine':  blue50,
  };

  static const Map<String, Color> _badgeText = {
    'vente':    white,
    'location': white,
    'en_cours': blue600,
    'signe':    slate900,
    'annule':   slate700,
    'termine':  blue500,
  };

  // --- Stat card variants ---
  static const List<StatCardColors> statVariants = [
    StatCardColors(leftBorder: blue500,  iconBg: blue100,  numberColor: blue600),
    StatCardColors(leftBorder: slate900, iconBg: slate100, numberColor: slate900),
    StatCardColors(leftBorder: blue400,  iconBg: blue50,   numberColor: blue500),
    StatCardColors(leftBorder: slate500, iconBg: slate50,  numberColor: slate700),
  ];

  // --- Role shield colors ---
  static Color roleColor(String role) => _roleColors[role] ?? slate400;

  static const Map<String, Color> _roleColors = {
    'SUPER_ADMIN':  slate900,
    'ADMIN_AGENCY': blue500,
    'AGENT':        blue400,
    'CLIENT':       slate400,
  };

  // --- Brand gradient ---
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue400, blue500],
  );
}

class StatCardColors {
  final Color leftBorder;
  final Color iconBg;
  final Color numberColor;

  const StatCardColors({
    required this.leftBorder,
    required this.iconBg,
    required this.numberColor,
  });
}
