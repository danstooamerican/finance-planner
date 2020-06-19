import 'dart:convert';

import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> createTransaction({Transaction transaction}) {
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

ThunkAction<AppState> editTransaction(Transaction transaction) {
  return (Store<AppState> store) async {
    return http
        .post(
          'http://zwerschke.net:2000/edit-transaction',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(transaction),
        )
        .then((value) => store.dispatch(fetchTransactions()));
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
      Iterable list = json.decode(utf8.decode(value.bodyBytes));
      List<Transaction> transactions = list.map((model) => Transaction.fromJson(model)).toList();

      store.dispatch(AddTransactionAction.multiple(transactions: transactions, overrideExisting: true));
    });
  };
}
