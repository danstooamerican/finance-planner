import 'dart:math';

import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:redux/redux.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(transactions: addTransactionReducer(state.transactions, action));
}

final addTransactionReducer = TypedReducer<List<Transaction>, IncrementAction>(_addTransaction);
List<Transaction> _addTransaction(List<Transaction> transactions, IncrementAction action) {
  Random rnd = new Random();

  double x = 100000;
  double amount = rnd.nextDouble() * x * 2 - x;

  return List.from(transactions)
    ..add(new Transaction(
        category: "category",
        description:
            "Paid for some fancy dinner. A crab robbed me but a disguised hero saved me. He swung his yellow umbrella like a champ.",
        amount: amount,
        dateTime: DateTime.now()));
}
