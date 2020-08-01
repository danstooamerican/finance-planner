import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';

@lazySingleton
class TransactionService with ReactiveServiceMixin {
  RxValue<double> _balance = RxValue<double>(initial: 0);
  double get balance => _balance.value;

  RxValue<List<Transaction>> _transactions = RxValue<List<Transaction>>(initial: List());
  List<Transaction> get transactions => _transactions.value;

  TransactionService() {
    listenToReactiveValues([_transactions, _balance]);
  }

  Future<Map> _getHeader() async {
    final token = await _getJWTToken();

    Map<String, String> header = HashMap.from({
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: token,
    });

    return header;
  }

  Future<String> _getJWTToken() async {
    final token = await FlutterSecureStorage().read(key: "jwt").catchError((e) => null);

    if (token == null) {
      throw HttpException("Missing jwt token");
    }

    return token;
  }

  String _getUrl(String endpoint) {
    return GlobalConfiguration().getString("backend") + '/' + endpoint;
  }

  Future createTransaction(Transaction transaction) async {
    return http
        .post(
      _getUrl('add-transaction'),
      headers: await _getHeader(),
      body: jsonEncode(transaction),
    )
        .then((value) {
      List<Transaction> newTransactions = _transactions.value;
      newTransactions.add(transaction);
      _transactions.value = newTransactions;
      fetchTransactions();
    });
  }

  Future editTransaction(Transaction transaction) async {
    return http
        .post(
          _getUrl('edit-transaction'),
          headers: await _getHeader(),
          body: jsonEncode(transaction),
        )
        .then((value) => fetchTransactions());
  }

  Future deleteTransaction(int id) async {
    return http
        .post(
          _getUrl('delete-transaction'),
          headers: await _getHeader(),
          body: jsonEncode(id),
        )
        .then((value) => fetchTransactions());
  }

  Future<void> fetchTransactions() async {
    http
        .get(
      _getUrl('transactions'),
      headers: await _getHeader(),
    )
        .then((value) async {
      Iterable list = json.decode(utf8.decode(value.bodyBytes));
      List<Transaction> transactions = list.map((model) => Transaction.fromJson(model)).toList();

      _balance.value = await _getCurrentMonthBalance();

      _transactions.value = transactions;
    });
  }

  Future<double> _getCurrentMonthBalance() async {
    return http
        .get(
      _getUrl('current-month-balance'),
      headers: await _getHeader(),
    )
        .then((value) {
      return double.parse(value?.body) ?? 0;
    });
  }

  Future<List<Category>> getCategories() async {
    return http
        .get(
      _getUrl('categories'),
      headers: await _getHeader(),
    )
        .then((value) {
      Iterable list = json.decode(utf8.decode(value.bodyBytes));

      return list.map((model) => Category.fromJson(model)).toList();
    });
  }
}
