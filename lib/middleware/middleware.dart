import 'dart:convert';

import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> createTransaction({double amount, DateTime date, String description, String category}) {
  TransactionDTO transaction = TransactionDTO(category: category, description: description, amount: amount, date: date);
  return (Store<AppState> store) async {
    return http
        .post(
      'http://10.0.2.2:8080/add-transaction',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(transaction),
    )
        .then((value) {
      store.dispatch(AddTransactionAction.single(
        id: int.parse(value.body),
        date: transaction.date,
        description: transaction.description,
        amount: transaction.amount,
        category: transaction.category,
      ));
    });
  };
}

ThunkAction<AppState> fetchTransactions() {
  return (Store<AppState> store) async {
    List<Transaction> transactions = List();

    for (int i = 0; i < 7; i++) {
      transactions.add(
        Transaction(
          id: 1,
          amount: 3,
          category: "cate",
          dateTime: DateTime.now(),
          description: "from API",
        ),
      );
    }

    store.dispatch(AddTransactionAction.multiple(transactions: transactions, overrideExisting: true));
  };
}

class TransactionDTO {
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  TransactionDTO({this.category, this.description, this.amount, this.date});

  TransactionDTO.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        category = json['category'],
        date = json['date'],
        description = json['email'];

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toString().substring(0, 10), //TODO: make this more robust
    };
  }
}
