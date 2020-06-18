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
      'http://zwerschke.net:2000/add-transaction',
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
    http.get(
      'http://zwerschke.net:2000/transactions',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((value) {
      Iterable list = json.decode(value.body);
       List<Transaction> transactions = list.map((model) => Transaction.fromJson(model)).toList();

      store.dispatch(AddTransactionAction.multiple(transactions: transactions, overrideExisting: true));
    });
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
        date = DateTime.parse(json['date']),
        description = json['description'];

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toString().substring(0, 10), //TODO: make this more robust
    };
  }
}
