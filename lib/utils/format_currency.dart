import 'package:intl/intl.dart';

class FormatCurrency {
  String format(double amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(amount);
  }
}
