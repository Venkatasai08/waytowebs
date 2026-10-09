import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _shortDateFormatter = DateFormat('dd MMM yyyy');

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }
}
