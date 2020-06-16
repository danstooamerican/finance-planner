import 'package:flutter/cupertino.dart';

class Transaction {
  final int id;
  final DateTime dateTime;
  final String description;
  final String category;
  final double amount;

  Transaction({
    @required this.id,
    @required this.category,
    @required this.description,
    @required this.amount,
    @required this.dateTime,
  });

  DateTime get date {
    return new DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
