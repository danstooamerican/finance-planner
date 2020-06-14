import 'package:flutter/cupertino.dart';

class Transaction {
  final DateTime date;
  final String description;
  final String category;
  final double amount;

  Transaction({
    @required this.category,
    @required this.description,
    @required this.amount,
    @required this.date,
  });
}
