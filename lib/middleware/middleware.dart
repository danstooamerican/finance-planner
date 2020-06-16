import 'dart:convert';

import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:http/http.dart' as http;

ThunkAction<AppState> createTransaction({double amount, DateTime date, String description, String category}) {
  TransactionDTO transaction = TransactionDTO(category: category, description: description, amount: amount, date: date);
  return (Store<AppState> store) async {
    return http
        .post(
          'https://localhost/add-transaction',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(transaction),
        )
        .then((value) => store.dispatch(AddTransactionAction(
              id: int.parse(value.body),
              date: transaction.date,
              description: transaction.description,
              amount: transaction.amount,
              category: transaction.category,
            )));
  };
}

class TransactionDTO {
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  TransactionDTO({this.category, this.description, this.amount, this.date});
}
