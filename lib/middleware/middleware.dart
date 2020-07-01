import 'dart:convert';
import 'dart:io';

import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

Future<String> _getJWTToken() async {
  final token = await FlutterSecureStorage().read(key: "jwt").catchError((e) => null);

  if (token == null) {
    throw HttpException("Missing jwt token");
  }

  return token;
}

ThunkAction<AppState> createTransaction({Transaction transaction}) {
  return (Store<AppState> store) async {
    final token = await _getJWTToken();

    return http
        .post(
      GlobalConfiguration().getString("backend") + '/add-transaction',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
      body: jsonEncode(transaction),
    )
        .then(
      (value) {
        store.dispatch(fetchTransactions());
      },
    );
  };
}

ThunkAction<AppState> editTransaction(Transaction transaction) {
  return (Store<AppState> store) async {
    final token = await _getJWTToken();

    return http
        .post(
          GlobalConfiguration().getString("backend") + '/edit-transaction',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: token,
          },
          body: jsonEncode(transaction),
        )
        .then(
          (value) => store.dispatch(fetchTransactions()),
        );
  };
}

ThunkAction<AppState> deleteTransaction(int id) {
  return (Store<AppState> store) async {
    final token = await _getJWTToken();

    return http
        .post(
          GlobalConfiguration().getString("backend") + '/delete-transaction',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: token,
          },
          body: jsonEncode(id),
        )
        .then(
          (value) => store.dispatch(fetchTransactions()),
        );
  };
}

ThunkAction<AppState> fetchTransactions() {
  return (Store<AppState> store) async {
    final token = await _getJWTToken();

    http.get(
      GlobalConfiguration().getString("backend") + '/transactions',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
    ).then((value) {
      Iterable list = json.decode(utf8.decode(value.bodyBytes));
      List<Transaction> transactions = list.map((model) => Transaction.fromJson(model)).toList();

      store.dispatch(AddTransactionAction.multiple(transactions: transactions, overrideExisting: true));
    });
  };
}

Future getCategories() {
  return new Future(() async {
    final token = await _getJWTToken();

    return http.get(
      GlobalConfiguration().getString("backend") + '/categories',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
    );
  });
}
