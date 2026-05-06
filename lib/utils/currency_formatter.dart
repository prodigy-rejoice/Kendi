import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat('#,##0', 'en_US');

  static String formatNGN(double amount) {
    return '₦${_formatter.format(amount.round())}';
  }
}
