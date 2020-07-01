import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:flutter/cupertino.dart';

class AddTransactionAction {
  final List<Transaction> transactions = List();
  final bool overrideExisting;

  factory AddTransactionAction.single({
    @required int id,
    @required DateTime date,
    @required String description,
    @required double amount,
    @required Category category,
  }) {
    List<Transaction> transactions = List();
    transactions.add(
      new Transaction(
        id: id,
        category: category,
        description: description,
        amount: amount,
        dateTime: date,
      ),
    );

    return AddTransactionAction.multiple(transactions: transactions, overrideExisting: false);
  }

  AddTransactionAction.multiple({
    @required List<Transaction> transactions,
    this.overrideExisting = false,
  }) {
    for (Transaction transaction in transactions) {
      this.transactions.add(transaction);
    }
  }
}
