import 'package:flutter/cupertino.dart';

class AddTransactionAction {
  final int id;
  final DateTime date;
  final String description;
  final double amount;
  final String category;

  AddTransactionAction({
    @required this.id,
    @required this.date,
    @required this.description,
    @required this.amount,
    @required this.category,
  });
}
