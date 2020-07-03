import 'dart:convert';
import 'dart:io';

import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class TransactionService {
  Future<String> _getJWTToken() async {
    final token = await FlutterSecureStorage().read(key: "jwt").catchError((e) => null);

    if (token == null) {
      throw HttpException("Missing jwt token");
    }

    return token;
  }

  Future createTransaction(Transaction transaction) async {
    final token = await _getJWTToken();

    return http.post(
      GlobalConfiguration().getString("backend") + '/add-transaction',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
      body: jsonEncode(transaction),
    );
  }

  Future editTransaction(Transaction transaction) async {
    final token = await _getJWTToken();

    return http.post(
      GlobalConfiguration().getString("backend") + '/edit-transaction',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
      body: jsonEncode(transaction),
    );
  }

  Future deleteTransaction(int id) async {
    final token = await _getJWTToken();

    return http.post(
      GlobalConfiguration().getString("backend") + '/delete-transaction',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
      body: jsonEncode(id),
    );
  }

  Future<List<Transaction>> fetchTransactions() async {
    final token = await _getJWTToken();

    return http.get(
      GlobalConfiguration().getString("backend") + '/transactions',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
    ).then((value) {
      Iterable list = json.decode(utf8.decode(value.bodyBytes));
      List<Transaction> transactions = list.map((model) => Transaction.fromJson(model)).toList();

      return transactions;
    });
  }

  Future<List<Category>> getCategories() async {
    final token = await _getJWTToken();

    return http.get(
      GlobalConfiguration().getString("backend") + '/categories',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
    ).then((value) {
      Iterable list = json.decode(utf8.decode(value.bodyBytes));

      return list.map((model) => Category.fromJson(model)).toList();
    });
  }
}
