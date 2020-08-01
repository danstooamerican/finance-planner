import 'dart:ui';

import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';

@injectable
class TransactionListViewModel extends ReactiveViewModel {
  final TransactionService _transactionService;

  List<Transaction> get transactions {
    List<Transaction> transactions = _transactionService.transactions;
    transactions.sort((t1, t2) {
      int dateCompare = t2.dateTime.compareTo(t1.dateTime);

      if (dateCompare == 0) {
        return t2.id.compareTo(t1.id);
      }

      return dateCompare;
    });

    return transactions;
  }

  bool get hasTransactions => (transactions?.length ?? 0) > 0;

  int get amtTransactions => _transactionService.transactions.length;

  String get balance => _transactionService?.balance?.toMoneyFormatWithSign() ?? '';
  Color get balanceColor => _transactionService?.balance?.toMoneyColor();

  TransactionListViewModel(this._transactionService) {
    updateTransactionList();
  }

  Future<void> updateTransactionList() async {
    await runBusyFuture(
      _transactionService.fetchTransactions(),
      busyObject: transactions,
    );
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_transactionService];
}
