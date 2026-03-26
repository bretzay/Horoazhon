import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currencyFull = NumberFormat('#,##0.00', 'fr_FR');
  static final _currencyShort = NumberFormat('#,##0', 'fr_FR');
  static final _dateFmt = DateFormat('dd/MM/yyyy');

  static String formatCurrency(double value) {
    return '${_currencyFull.format(value)} EUR';
  }

  static String formatCurrencyShort(double value) {
    return '${_currencyShort.format(value)} EUR';
  }

  static String formatRent(double value) {
    return '${_currencyShort.format(value)} EUR/mois';
  }

  static String formatDate(DateTime date) {
    return _dateFmt.format(date);
  }

  /// Parse an ISO 8601 date string and format as dd/MM/yyyy.
  /// Returns the raw string if parsing fails.
  static String formatDateString(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return _dateFmt.format(parsed);
  }

  static String formatBienId(int id) => 'BI-$id';
  static String formatContratId(int id) => 'CTR-$id';
  static String formatAgenceId(int id) => 'AG-$id';

  static String formatArea(double area) {
    return '${area.toStringAsFixed(0)} m\u00B2';
  }

  // --- Property type icons & labels ---

  static const _typeIcons = <String, IconData>{
    'APPARTEMENT': Icons.apartment,
    'MAISON': Icons.house,
    'STUDIO': Icons.weekend,
    'TERRAIN': Icons.terrain,
  };

  static const _typeLabels = <String, String>{
    'APPARTEMENT': 'Appartement',
    'MAISON': 'Maison',
    'STUDIO': 'Studio',
    'TERRAIN': 'Terrain',
  };

  static IconData typeIcon(String? type) =>
      _typeIcons[type] ?? Icons.home_outlined;

  static String typeLabel(String? type) =>
      _typeLabels[type] ?? type ?? '';

  static const typeKeys = ['APPARTEMENT', 'MAISON', 'STUDIO', 'TERRAIN'];
}
