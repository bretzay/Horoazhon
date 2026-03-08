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

  static String formatBienId(int id) => 'BI-$id';
  static String formatContratId(int id) => 'CTR-$id';
  static String formatAgenceId(int id) => 'AG-$id';

  static String formatArea(double area) {
    return '${area.toStringAsFixed(0)} m\u00B2';
  }
}
