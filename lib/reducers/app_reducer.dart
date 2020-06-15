import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:redux/redux.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(transactions: addTransactionReducer(state.transactions, action));
}

final addTransactionReducer = TypedReducer<List<Transaction>, AddTransactionAction>(_addTransaction);
List<Transaction> _addTransaction(List<Transaction> transactions, AddTransactionAction action) {
  return List.from(transactions)
    ..add(new Transaction(
      category: action.category,
      description: action.description,
      amount: action.amount,
      dateTime: action.date,
    ));
}
