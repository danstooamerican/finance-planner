import 'dart:ui';

import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';

@injectable
class TransactionListViewModel extends BaseViewModel {
  final TransactionService _transactionService;

  List<Transaction> _transactions;
  List<Transaction> get transactions => _transactions ?? [];
  int get amtTransactions => _transactions?.length ?? 0;

  String get balance => _getBalance()?.toMoneyFormatWithSign() ?? '';
  Color get balanceColor => _getBalance()?.toMoneyColor();

  TransactionListViewModel(this._transactionService) {
    updateTransactionList();
  }

  double _getBalance() {
    return _transactions?.fold(0, (previousValue, Transaction element) => previousValue + element.amount);
  }

  Future<void> updateTransactionList() async {
    _transactions = await runBusyFuture(
      _transactionService.fetchTransactions().then(
        (value) {
          value.sort((t1, t2) {
            int dateCompare = t2.dateTime.compareTo(t1.dateTime);

            if (dateCompare == 0) {
              return t2.id.compareTo(t1.id);
            }

            return dateCompare;
          });

          return value;
        },
      ),
      busyObject: _transactions,
    );

    notifyListeners();
  }
}
