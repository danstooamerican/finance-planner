import 'package:intl/intl.dart';

extension StringFormatting on String {
  static final String moneyRegex = r'^(\-?[0-9]+(?:\,[0-9]{1,2})?)$';

  bool matches(RegExp regex) {
    Match match = regex.firstMatch(this);

    return match != null && match.end == this.length;
  }

  double parseMoney() {
    NumberFormat f = NumberFormat.currency(locale: "de_DE");

    int sign = 1;
    String toFormat = sanitizeMoneyString(this);
    if (this.startsWith("-")) {
      toFormat = this.substring(1);
      sign = -1;
    }

    return sign * f.parse(toFormat);
  }

  bool isMoney() {
    return sanitizeMoneyString(this).matches(RegExp(moneyRegex));
  }
}

String sanitizeMoneyString(String money) {
  return money.replaceAll(".", ",");
}

extension DateTimeFormatting on DateTime {
  String toDateFormat() {
    DateFormat f = new DateFormat('dd.MM.yyyy');

    return f.format(this);
  }

  bool isOnDifferentDay(DateTime date) {
    return this.difference(date).inDays.abs() >= 1;
  }
}

extension DoubleFormatting on double {
  String toMoneyFormatWithSign() {
    NumberFormat f = NumberFormat.currency(locale: "de_DE", symbol: "€");

    return (this > 0 ? "+" : "") + f.format(this);
  }
}
