import 'package:intl/intl.dart';

/// Centralised formatting so the same currency/date style is used
/// everywhere. Swap the locale/symbol here if you need a different
/// currency — nothing else in the app needs to change.
class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM yyyy');
  static final DateFormat _listDate = DateFormat('dd MMM');

  static String currency(double amount) => _currency.format(amount);

  static String monthYear(DateTime date) => _monthYear.format(date);

  static String shortDate(DateTime date) => _shortDate.format(date);

  static String listDate(DateTime date) => _listDate.format(date);
}
